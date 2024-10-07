local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_close_confirmation = "NeverPrompt"
config.initial_cols = 150
config.initial_rows = 50
config.enable_tab_bar = false
config.font = wezterm.font {
  family = 'JetBrains Mono',
  weight = "Bold",
}
config.font_size = 14.5 
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.keys = {
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "n",
    mods = "CMD",
    action = wezterm.action.SpawnCommandInNewWindow({cwd = wezterm.home_dir }),
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab{confirm=false}
  },
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

config.colors = {
  foreground = '#c0c0c0',
  background = '#101010',

  ansi = {
    '#151515',
    '#ff4d4d',
    '#cff72f',
    '#62fd62',
    '#4b94ff',
    '#ff7001',
    '#ffffff',
    '#d0d0d0',
  },
  brights = {
    '#151515',
    '#ff0000',
    '#cff72f',
    '#62fd62',
    '#4b94ff',
    '#ff7001',
    '#ffffff',
    '#ffffff',
  },

}

return config

