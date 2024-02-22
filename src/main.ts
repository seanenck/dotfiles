import { join } from "std/path/mod.ts";
import { uncommit } from "./uncommitted.ts";
import { sync } from "./sync.ts";
import { loadLockboxConfig, lockbox } from "./lb.ts";
import {
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";

const COMMANDS: Map<string, (args: Array<string>) => void> = new Map();
COMMANDS.set("git-uncommitted", uncommit);
COMMANDS.set("sys-update", (_: Array<string>) => {
  sync();
});
COMMANDS.set(KnownCommands.Lockbox, lockbox);
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
    case "compile": {
      const allowedEnv = Object.values(EnvironmentVariable).map(String).join(
        ",",
      );
      const lb = loadLockboxConfig(Deno.env.get("CI") === "true");
      const allowedRun = Object.values(KnownCommands).map(String).concat(
        [lb.command],
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
