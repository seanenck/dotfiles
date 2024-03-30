import { join } from "std/path/mod.ts";
import { existsSync } from "std/fs/mod.ts";
import { red, yellow } from "std/fmt/colors.ts";
import {
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";

class Result {
  constructor(
    readonly has: boolean,
    private readonly sub: string,
    private readonly dir: string,
  ) {
  }
  quick(early: boolean) {
    if (!early) {
      return;
    }
    if (this.has) {
      color("dirty", red);
      Deno.exit(1);
    }
  }
  display(): string {
    return `${this.dir} (${this.sub})`;
  }
}

class Git {
  private args: Array<string>;
  private filter?: string;
  private negate: boolean;
  constructor(private readonly sub: string, args: Array<string>) {
    this.args = [sub, ...args];
    this.negate = false;
  }
  setFilter(filter: string, negate: boolean): Git {
    this.filter = filter;
    this.negate = negate;
    return this;
  }
  private toCommand(dir: string): Array<string> {
    return ["-C", dir, ...this.args];
  }
  private check(dir: string, output: string): Result {
    let res = output !== "";
    if (this.filter !== undefined) {
      const matched = new RegExp(this.filter).test(output);
      if (this.negate) {
        if (matched) {
          res = false;
        } else {
          res = true;
        }
      } else {
        res = matched;
      }
    }
    return new Result(res, this.sub, dir);
  }
  command(dir: string): Result {
    const cmd = this.toCommand(dir);
    const proc = new Deno.Command(KnownCommands.Git, {
      args: cmd,
      stdout: "piped",
    });
    const stdout = proc.outputSync().stdout;
    return this.check(dir, new TextDecoder().decode(stdout).trim());
  }
}

function color(text: string, callback: (t: string) => string) {
  console.log(callback(`(${text})`));
}

function stat(dir: string, early: boolean): Array<string> {
  new Git("update-index", ["-q", "--refresh"]).command(dir);
  const diffIndex = new Git("diff-index", ["--name-only", "HEAD", "--"])
    .command(
      dir,
    );
  diffIndex.quick(early);
  const status = new Git("status", ["-sb"]).setFilter("\\[ahead", false)
    .command(
      dir,
    );
  status.quick(early);
  const lsFiles = new Git("ls-files", ["--other", "--exclude-standard"])
    .command(dir);
  lsFiles.quick(early);
  const branch = new Git("branch", ["--show-current"]).setFilter(
    "^(main|master)$",
    true,
  ).command(dir);
  branch.quick(early);
  if (early) {
    color("clean", yellow);
    Deno.exit(0);
  }
  const lines: Array<string> = [];
  [diffIndex, status, lsFiles, branch].forEach((e) => {
    if (e.has) {
      const disp = e.display();
      if (!lines.includes(disp)) {
        lines.push(disp);
      }
    }
  });
  return lines;
}

export function uncommit(args: Array<string>) {
  const dirs = getEnv(EnvironmentVariable.GitUncommit);
  let quiet = false;
  if (args.length > 0) {
    switch (args[0]) {
      case "--pwd": {
        const cwd = Deno.cwd();
        const working = new Git("rev-parse", ["--is-inside-work-tree"])
          .setFilter(
            "true",
            false,
          ).command(cwd);
        if (working.has) {
          stat(cwd, true);
        }
        return;
      }
      case "--quiet":
        quiet = true;
        break;
      default:
        messageAndExitNonZero("unknown subcommand");
    }
  }
  let items: Array<string> = [];
  dirs.trim().split(" ").forEach((d) => {
    for (const entry of Deno.readDirSync(d)) {
      if (entry.isDirectory) {
        const pathing = join(d, entry.name);
        if (existsSync(join(pathing, ".git"))) {
          const stats = stat(pathing, false);
          if (stats.length > 0) {
            if (quiet) {
              Deno.exit(1);
            }
            items = items.concat(stats);
          }
        }
      }
    }
  });
  items.sort().forEach((e) => {
    console.log(e);
  });
  if (items.length > 0) {
    Deno.exit(1);
  }
}
