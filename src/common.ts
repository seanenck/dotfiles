export const BASH_ARG = "--bash";
export enum EnvironmentVariable {
  Home = "HOME",
  Version = "VERSION",
  GitSources = "GIT_SOURCES",
  GitUncommit = "GIT_UNCOMMIT",
  TaskCache = "TASK_CACHE",
}
export enum KnownCommands {
  Sort = "sort",
  Git = "git",
  Brew = "brew",
  Diff = "diff",
  Sips = "sips",
  AVConvert = "avconvert",
  PBCopy = "pbcopy",
  PBPaste = "pbpaste",
  KeepassXCCLI = "keepassxc-cli",
  Lockbox = "lb",
}
export function messageAndExitNonZero<T>(message?: string): Promise<T> {
  if (message !== undefined) {
    Deno.stderr.write(new TextEncoder().encode(message));
  }
  Deno.exit(1);
}

export function getEnv(key: EnvironmentVariable): string {
  const val = Deno.env.get(key.toString());
  if (val === undefined) {
    messageAndExitNonZero(`${key} is not set`);
    return "";
  }
  return val;
}
