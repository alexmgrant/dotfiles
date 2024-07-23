local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

  config.color_scheme = 'Tokyo Night'

  config.font = wezterm.font {
    family = "MonoLisa",
    weight = "Regular",
  }
  config.font_size = 10.0

  config.enable_tab_bar = false
  config.use_fancy_tab_bar = false
  config.window_close_confirmation = 'NeverPrompt'

  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }

  config.window_frame = {
    border_left_width = '0',
    border_right_width = '0',
    border_bottom_height = '0',
    border_top_height = '0',
  }


  config.keys = {
    { key="1", mods="ALT", action=act{ ActivateTab=0 }},
    { key="2", mods="ALT", action=act{ ActivateTab=1 }},
    { key="3", mods="ALT", action=act{ ActivateTab=2 }},
    { key="4", mods="ALT", action=act{ ActivateTab=3 }},
    { key="5", mods="ALT", action=act{ ActivateTab=4 }},
    { key="6", mods="ALT", action=act{ ActivateTab=5 }},
    { key="7", mods="ALT", action=act{ ActivateTab=6 }},
    { key="8", mods="ALT", action=act{ ActivateTab=7 }},
    { key="9", mods="ALT", action=act{ ActivateTab=8 }},
    { key="w", mods="ALT", action=act{ CloseCurrentTab = { confirm=false }}},
    { key="t", mods="ALT", action=act { SpawnTab="CurrentPaneDomain" }},
  }

return config

