local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

config.window_close_confirmation = 'NeverPrompt'
config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.font = wezterm.font('JetBrains Mono')
config.enable_tab_bar = false
config.window_background_opacity = 0.85
config.default_cursor_style = 'BlinkingBar'
config.initial_cols = 80
config.initial_rows = 25

config.color_scheme = 'Vesper'
config.color_schemes = {
  ['Vesper'] = {
    foreground = '#FFFFFF',
    background = '#101010',
    cursor_bg = '#FFC799',
    cursor_fg = '#101010',
    cursor_border = '#FFC799',
    selection_bg = 'rgba(50% 50% 50% 50%)',
    scrollbar_thumb = 'rgba(50% 50% 50% 50%)',
    split = '#505050',
    ansi = {
      '#101010',
      '#F5A191',
      '#90B99F',
      '#E6B99D',
      '#ACA1CF',
      '#E29ECA',
      '#EA83A5',
      '#A0A0A0',
    },
    brights = {
      '#7E7E7E',
      '#FF8080',
      '#99FFE4',
      '#FFC799',
      '#B9AEDA',
      '#ECAAD6',
      '#F591B2',
      '#FFFFFF',
    },
  },
}

return config
