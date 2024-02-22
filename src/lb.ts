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
    root: string,
    database: string,
    key: Array<string>,
    keyfile: string,
  ) {
    this.database = join(root, database);
    this.keyfile = join(root, keyfile);
    this.command = key[0];
    this.command_args = key.slice(1);
    this.inCommand = key;
  }
  env() {
    const exports = {
      "KEY": this.inCommand.join(" "),
      "KEYFILE": this.keyfile,
      "DATABASE": this.database,
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
    return new App("", "", ["echo"], "");
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
  );
}

export async function lockbox(args: Array<string>) {
  if (args.length === 0) {
    messageAndExitNonZero("arguments required");
  }
  const command = args[0];
  const app = loadLockboxConfig(false);
  switch (command) {
    case "env":
      app.env();
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
