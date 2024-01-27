import { join } from "std/path/mod.ts";
import { transcode } from "./transcode.ts";
import { uncommit } from "./uncommitted.ts";
import { oclone } from "./oclone.ts";
import { sync } from "./sync.ts";
import { loadLockboxConfig, lockbox } from "./lb.ts";
import {
  BASH_ARG,
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";
import { existsSync } from "std/fs/exists.ts";

const LB_COMMAND = KnownCommands.Lockbox;
const OCLONE_COMMAND = "git-oclone";
const COMMANDS: Map<string, (args: Array<string>) => void> = new Map();
COMMANDS.set("transcode-media", (_: Array<string>) => {
  transcode();
});
COMMANDS.set(OCLONE_COMMAND, oclone);
COMMANDS.set("git-uncommitted", uncommit);
COMMANDS.set(LB_COMMAND, lockbox);
COMMANDS.set("sys-update", (_: Array<string>) => {
  sync();
});
const COMPLETIONS = [LB_COMMAND, OCLONE_COMMAND];
const EXECUTABLE = "utility-wrapper";

function main() {
  if (Deno.args.length === 0) {
    messageAndExitNonZero("invalid args, command required");
  }
  const args: Array<string> = [];
  let first = true;
  let command = "";
  for (const arg of Deno.args) {
    if (first) {
      command = arg;
      first = false;
    } else {
      args.push(arg);
    }
  }
  const cb = COMMANDS.get(command);
  if (cb !== undefined) {
    cb(args);
    return;
  }
  switch (command) {
    case "bash": {
      if (args.length !== 1) {
        messageAndExitNonZero("directory required");
      }
      const target = args[0];
      if (!existsSync(target)) {
        Deno.mkdirSync(target);
      }
      for (const key of COMPLETIONS) {
        const completion = join(target, key);
        if (existsSync(completion)) {
          continue;
        }
        const cb = COMMANDS.get(key);
        if (cb === undefined) {
          messageAndExitNonZero(
            `unable to resolve completion callback: ${key}`,
          );
          return;
        }
        cb([BASH_ARG, completion]);
      }
      break;
    }
    case "compile": {
      const allowedEnv = Object.values(EnvironmentVariable).map(String).join(
        ",",
      );
      const lb = loadLockboxConfig(Deno.env.get("CI") === "true");
      const allowedRun = Object.values(KnownCommands).map(String).concat(
        [lb.command, lb.applicationPath()],
      ).join(",");
      const home = getEnv(EnvironmentVariable.Home);
      const args = [
        "compile",
        `--allow-env=${allowedEnv}`,
        `--allow-run=${allowedRun}`,
        `--allow-write=${home}`,
        `--allow-read=${home}`,
        "-o",
        "build/utility-wrapper",
        "main.ts",
      ];
      console.log(`compile args: ${args}`);
      const cmd = new Deno.Command("deno", {
        stdout: "inherit",
        stderr: "inherit",
        args: args,
      });
      if (cmd.outputSync().code !== 0) {
        messageAndExitNonZero("deno compile failed");
      }
      break;
    }
    case "generate": {
      if (args.length !== 1) {
        messageAndExitNonZero("target required");
      }
      const vers = getEnv(EnvironmentVariable.Version);
      const target = args[0];
      for (const command of COMMANDS.keys()) {
        Deno.writeTextFileSync(
          join(target, command),
          `#!/usr/bin/env bash
if [[ -n "$1" ]]; then
  if [[ "$1" == "--version" ]]; then
    echo "version: ${vers}"
    exit 0
  fi
fi
exec ${EXECUTABLE} ${command} $@`,
          {
            mode: 0o755,
          },
        );
      }
      break;
    }
    default:
      messageAndExitNonZero("unknown subcommand");
  }
}

if (import.meta.main) {
  main();
}
