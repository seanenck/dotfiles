import { basename, join } from "std/path/mod.ts";
import { existsSync, moveSync } from "std/fs/mod.ts";
import { parse as parseConfig } from "std/yaml/mod.ts";
import {
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";

interface Config {
  apps: AppSet;
  neovim: Array<string>;
}

interface AppSet {
  remotes: Array<string>;
  filters: Array<string>;
}

export function sync() {
  const home = getEnv(EnvironmentVariable.Home);
  const tasks = getEnv(EnvironmentVariable.TaskCache);
  for (const sub of ["update", "upgrade"]) {
    console.log(`=> brew operation: ${sub}`);
    if (!command(KnownCommands.Brew, [sub], undefined)) {
      messageAndExitNonZero(
        `brew ${sub} failed`,
      );
    }
  }
  const brewConfig = join(tasks, "brew");
  if (!existsSync(brewConfig)) {
    Deno.mkdir(brewConfig);
  }
  const brewConfigFile = join(brewConfig, "Brewfile");
  if (existsSync(brewConfigFile)) {
    Deno.removeSync(brewConfigFile);
  }
  if (!command(KnownCommands.Brew, ["bundle", "dump"], brewConfig)) {
    messageAndExitNonZero("failed to dump brew information");
  }
  const config = join(home, ".config");
  const configFile = join(config, "voidedtech", "upstreams.yaml");
  const packs = join(config, "nvim", "pack", "plugins", "start");
  const data = new TextDecoder().decode(Deno.readFileSync(configFile));
  const cfg = parseConfig(data) as Config;
  for (const plugin of cfg.neovim) {
    const base = basename(plugin);
    const dest = join(packs, base);
    let args: Array<string> = [
      "clone",
      `https://github.com/${plugin}`,
      dest,
      "--single-branch",
    ];
    if (existsSync(dest)) {
      const parse = new Deno.Command(KnownCommands.Git, {
        args: ["-C", dest, "rev-parse", "--abbrev-ref", "HEAD"],
        stdout: "piped",
      });
      const { code, stdout } = parse.outputSync();
      if (code !== 0) {
        console.log("failed to parse rev");
        continue;
      }
      const rev = new TextDecoder().decode(stdout).trim();
      args = ["-C", dest, "pull", "origin", rev];
    }
    console.log(`=> ${base}`);
    if (!command(KnownCommands.Git, args, undefined)) {
      console.log("plugin sync failed");
    }
    console.log();
  }
  const repoState = join(home, ".local", "state", "repos.current");
  const newState = `${repoState}.new`;
  const items: Array<string> = [];
  const isTag = cfg.apps.filters.map<RegExp>((x) => {
    return new RegExp(x);
  });
  for (const app of cfg.apps.remotes) {
    console.log(`=> getting state: ${app}`);
    const proc = new Deno.Command(KnownCommands.Git, {
      args: ["ls-remote", "--tags", `https://github.com/${app}`],
      stdout: "piped",
    });
    const { code, stdout } = proc.outputSync();
    if (code !== 0) {
      console.log("unable to get state");
      continue;
    }
    for (const line of new TextDecoder().decode(stdout).trim().split("\n")) {
      const parts = line.replaceAll("\t", " ").split(" ");
      if (parts.length < 2) {
        continue;
      }
      let skipped = false;
      const tag = parts[1];
      isTag.forEach((x) => {
        if (!x.test(tag)) {
          skipped = true;
        }
      });
      if (skipped) {
        continue;
      }
      items.push(`${app}: ${line}`);
    }
  }
  Deno.writeTextFileSync(newState, items.join("\n"));
  if (!existsSync(repoState)) {
    Deno.writeTextFileSync(repoState, "");
  }
  if (!command(KnownCommands.Diff, [repoState, newState], undefined)) {
    console.log("===\napplication update detected\n===");
    if (!confirm("update completed?")) {
      return;
    }
  }

  moveSync(newState, repoState, {
    overwrite: true,
  });
}

function command(
  exe: KnownCommands,
  args: Array<string>,
  cwd: string | undefined,
): boolean {
  const proc = new Deno.Command(exe, {
    args: args,
    stdout: "inherit",
    stderr: "inherit",
    cwd: cwd,
  });
  return proc.outputSync().code === 0;
}
