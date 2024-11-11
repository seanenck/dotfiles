local goos = os.getenv("GOOS")
if goos == "linux" then
  register(".bash_aliases")
  register(".bash_profile")
  register(".bashrc")
  register(".justfile")
  register(".config/bat/*")
  register(".config/blap/*")
  register(".config/git/*")
  register(".config/nvim/*")
  register(".config/shellrc/*")
  register(".config/user-dirs.dirs")
  register(".ssh/*")
  local session = os.getenv("DESKTOP_SESSION")
  if session == "sway" then
    register(".config/waybar/*")
    register(".config/rofi/*")
    register(".config/sway/*")
    local term = os.getenv("TERMINAL_EMULATOR")
    if term ~= nil then
      local term = ".config/" .. term .. "/"
      if exists(term) then
          register(term .. "*")
      end
    end
  end
  local hostos = os.getenv("HOST_OS")
  local is_fedora = hostos == "fedora"
  local is_tumbleweed = hostos == "opensuse-tumbleweed"
  if is_fedora or is_tumbleweed then
    register("!.config/blap/apps/age.yaml")
    register("!.config/blap/apps/delta.yaml")
    register("!.config/blap/apps/just.yaml")
    register("!.config/blap/apps/nvim.yaml")
    register("!.config/blap/apps/shellcheck.yaml")
    register("!.config/blap/apps/bat.yaml")
    register("!.config/blap/apps/rg.yaml")
  end
  if is_fedora then
    register("!.config/sway/config.d/*")
  end
  if is_tumbleweed then
    register("!.config/blap/apps/efm.yaml")
    register("!.config/blap/apps/image.yaml")
    register(".config/osc/*")
  end
end
