import { join } from "std/path/join.ts";
import {
  BASH_ARG,
  EnvironmentVariable,
  getEnv,
  KnownCommands,
  messageAndExitNonZero,
} from "./common.ts";

const START = "start";
const STATUS = "status";
export const VM_COMMAND = "vm";
const NAME = `${VM_COMMAND}-vfu`;

function status(): boolean {
  const proc = new Deno.Command(KnownCommands.Screen, {
    args: ["-list"],
    stdout: "piped",
  });
  const stdout = new TextDecoder().decode(proc.outputSync().stdout);
  return stdout.trim().indexOf(NAME) > 0;
}

export function manageVM(args: Array<string>) {
  if (args.length === 0) {
    messageAndExitNonZero("argument required");
  }
  switch (args[0]) {
    case START: {
      if (status()) {
        console.log("already running");
        return;
      }
      const home = getEnv(EnvironmentVariable.Home);
      const config = join(home, ".local", "vm", "alpine.json");
      new Deno.Command(KnownCommands.Screen, {
        args: ["-S", NAME, "-d", "-m", "vfu", "--config", config],
      }).outputSync();
      break;
    }
    case STATUS: {
      let running = "down";
      if (status()) {
        running = "up";
      }
      console.log(running);
      break;
    }
    case BASH_ARG:
      if (args.length !== 2) {
        messageAndExitNonZero("target file required");
      }
      Deno.writeTextFileSync(
        args[1],
        `#!/usr/bin/env bash
_${VM_COMMAND}() {
  local cur
  if [ "$COMP_CWORD" -eq 1 ]; then
    cur=\${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "${STATUS} ${START}" -- "$cur") )
  fi
}

complete -F _${VM_COMMAND} -o bashdefault ${VM_COMMAND}`,
      );
      break;
    default:
      messageAndExitNonZero("unknown command");
  }
}
