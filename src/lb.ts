import { join } from "std/path/mod.ts";
import { existsSync } from "std/fs/mod.ts";
import { encodeHex } from "std/encoding/hex.ts";
import { parse } from "std/csv/mod.ts";
import { parse as parseConfig } from "std/yaml/mod.ts";
import {
  CONFIG_LOCATION,
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";

const GROUP_SEPARATOR = "/";

async function inOutCommand(
  stdin: Uint8Array,
  cmd: KnownCommands,
  args: Array<string>,
): Promise<string> {
  const command = new Deno.Command(cmd, {
    args: args,
    stdin: "piped",
    stdout: "piped",
  });
  const process = command.spawn();
  const writer = process.stdin.getWriter();
  writer.write(stdin);
  writer.releaseLock();
  await process.stdin.close();
  const result = await process.output();
  return new TextDecoder().decode(result.stdout).trim();
}

interface StoreConfig {
  root: string;
  key: Array<string>;
  keyfile: string;
  database: string;
  synced: string;
}

interface Config {
  store: StoreConfig;
}

class App {
  private readonly database: string;
  private readonly keyfile: string;
  command: string;
  private readonly command_args: Array<string>;
  private key?: Uint8Array;
  private readonly inCommand: Array<string>;
  constructor(
    readonly root: string,
    database: string,
    key: Array<string>,
    keyfile: string,
    readonly synced: string,
  ) {
    this.database = join(root, database);
    this.keyfile = join(root, keyfile);
    this.command = key[0];
    this.command_args = key.slice(1);
    this.inCommand = key;
  }
  gitStatus(dir: string): Array<string> {
    const proc = new Deno.Command(KnownCommands.Git, {
      args: ["-C", dir, "ls-files"],
      stdout: "piped",
    });
    const stdout = proc.outputSync().stdout;
    const files = new TextDecoder().decode(stdout).trim().split("\n");
    if (files.length === 0) {
      messageAndExitNonZero("no files found in git repository");
    }
    const pathed: Array<string> = [];
    files.forEach((x) => {
      pathed.push(join(dir, x));
    });
    const hashed = new Deno.Command(KnownCommands.Sha256Sum, {
      args: pathed,
      stdout: "piped",
      stderr: "inherit",
    });
    const results: Array<string> = [];
    let replacing = dir;
    if (!replacing.endsWith("/")) {
      replacing = `${dir}/`;
    }

    new TextDecoder().decode(hashed.outputSync().stdout).trim()
      .split("\n").sort().forEach((x) => {
        const p = x.replaceAll(replacing, "");
        results.push(p.trim());
      });
    return results;
  }
  resync() {
    const synced = this.gitStatus(this.synced);
    const current = this.gitStatus(this.root);
    let mismatch = true;
    if (current.length == synced.length) {
      mismatch = false;
      for (const i in synced) {
        if (synced[i] !== current[i]) {
          mismatch = true;
          break;
        }
      }
    }
    if (mismatch) {
      console.log(
        `\npasswords\n===\n- out-of-sync\n`,
      );
      console.log("<<<<<<<<<<<<");
      console.log(synced);
      console.log("============");
      console.log(current);
      console.log(">>>>>>>>>>>>");
    }
  }
  env() {
    const exports = {
      "KEY": this.inCommand.join(" "),
      "KEYFILE": this.keyfile,
      "DATABASE": this.database,
      "SYNCED": this.synced,
    };
    for (const [key, val] of Object.entries(exports)) {
      console.log(`export LB_${key}="${val}"`);
    }
  }
  private async keepassxc(
    store: string | undefined,
    arg: string,
    args: Array<string>,
  ): Promise<Array<string>> {
    if (this.key === undefined) {
      const proc = new Deno.Command(this.command, {
        args: this.command_args,
        stdout: "piped",
      });
      const stdout = proc.outputSync().stdout;
      this.key = new TextEncoder().encode(
        new TextDecoder().decode(stdout).trim(),
      );
    }
    let useStore = store;
    if (useStore === undefined) {
      useStore = this.database;
    }
    const appArgs: Array<string> = [
      arg,
      "--quiet",
      "--key-file",
      this.keyfile,
      useStore,
      ...args,
    ];
    const data = await inOutCommand(
      this.key,
      KnownCommands.KeepassXCCLI,
      appArgs,
    );
    return data.split("\n");
  }
  private async query(
    arg: string,
    args: Array<string>,
  ): Promise<Array<string>> {
    return await this.keepassxc(this.database, arg, args);
  }
  private async entry(
    entry: string,
  ): Promise<Array<string>> {
    if (entry.endsWith(GROUP_SEPARATOR)) {
      messageAndExitNonZero(
        "invalid entry, group detected",
      );
    }
    const args: Array<string> = ["--show-protected"];
    const allowed: Array<string> = ["Password", "Notes"];
    for (const allow of allowed) {
      const tryArgs = args.concat(["--attributes", allow, entry]);
      const val = await this.query("show", tryArgs);
      let viable = false;
      val.forEach((x) => {
        if (x.trim() !== "") {
          viable = true;
        }
      });
      if (viable) {
        return val;
      }
    }
    return messageAndExitNonZero<Array<string>>(
      "unable to find entry",
    );
  }
  async show(entry: string) {
    const val = await this.entry(entry);
    console.log(val.join("\n").trim());
  }
  async convert(store: string) {
    const data = await this.keepassxc(store, "export", ["--format", "csv"]);
    const parsed = parse(data.join("\n"), {
      skipFirstRow: true,
      strip: true,
    });
    const keys = new Map<string, Map<string, string>>();
    for (const record of parsed) {
      let entry = "";
      for (const item of ["Group", "Title", "Username"]) {
        const value = (record[item] as string).trim();
        if (value === "") {
          continue;
        }
        if (entry.length > 0) {
          entry = `${entry}/`;
        }
        entry = `${entry}${value}`;
      }
      const hashing: Array<string> = [];
      for (const item of ["Password", "TOTP", "Notes"]) {
        hashing.push((record[item] as string).trim());
      }
      const hashed = await hashValue(
        new TextEncoder().encode(hashing.join("")),
      );
      const obj = new Map<string, string>();
      obj.set("modtime", record["Last Modified"] as string);
      obj.set("hash", hashed);
      keys.set(entry, obj);
    }
    new Map([...keys].sort()).forEach((value, key) => {
      console.log(`${key}: {`);
      new Map([...value].sort()).forEach((v, k) => {
        console.log(`  ${k}: ${v}`);
      });
      console.log("}");
    });
  }
}

async function hashValue(value: Uint8Array): Promise<string> {
  const buffer = await crypto.subtle.digest(
    "SHA-256",
    value,
  );
  return encodeHex(buffer).substring(0, 7);
}

export function loadLockboxConfig(useDefaults: boolean): App {
  if (useDefaults) {
    return new App("", "", ["echo"], "", "");
  }
  const home = getEnv(EnvironmentVariable.Home);
  const config = join(home, ".config", CONFIG_LOCATION, "lb.yaml");
  if (!existsSync(config)) {
    messageAndExitNonZero("missing configuration file");
  }
  const data = new TextDecoder().decode(Deno.readFileSync(config));
  const yaml = parseConfig(data.replaceAll("~", home)) as Config;
  return new App(
    yaml.store.root,
    yaml.store.database,
    yaml.store.key,
    yaml.store.keyfile,
    yaml.store.synced,
  );
}

export async function lockbox(args: Array<string>) {
  if (args.length === 0) {
    messageAndExitNonZero("arguments required");
  }
  const command = args[0];
  const app = loadLockboxConfig(false);
  switch (command) {
    case "show":
      requireArgs(args, 2);
      await app.show(args[1]);
      break;
    case "env":
      app.env();
      break;
    case "resync":
      app.resync();
      break;
    case "conv":
      requireArgs(args, 2);
      await app.convert(args[1]);
      break;
    default:
      messageAndExitNonZero("unknown command");
  }
}

function requireArgs(args: Array<string>, count: number) {
  if (args.length !== count) {
    messageAndExitNonZero("invalid arguments passed");
  }
}
