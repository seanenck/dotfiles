export const CONFIG_LOCATION = "voidedtech";
export enum EnvironmentVariable {
  Home = "HOME",
  Version = "VERSION",
  GitUncommit = "GIT_UNCOMMIT",
}
export enum KnownCommands {
  Screen = "screen",
  Sort = "sort",
  Git = "git",
  Diff = "diff",
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
