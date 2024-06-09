local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then config = wezterm.config_builder() end

-- Settings
config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Symbols Nerd Font Mono",
})
config.font_size=16

config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.default_workspace = "main"
config.scrollback_lines = 5000
config.hide_tab_bar_if_only_one_tab = true
config.prefer_to_spawn_tabs = true

-- Startup params
config.initial_rows = 63
config.initial_cols = 126
config.default_cwd = "$HOME"

-- TODO: Fix
-- wezterm.on('gui-startup', function(cmd)
--     local tab, pane, window = mux.spawn_window(cmd or {})
--     window:set_position(500000, 0)
--   end)

-- Tabs
-- config.tab_max_width = 20
-- The filled in variant of the < or > symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- Set tab name to be the current dir
local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "." or string.gsub(current_dir, "(.*[/\\])(.*)", "%2")
end


wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = string.format(" %s  %s ~ %s  ", "❯", get_current_working_dir(tab))
	return {
		{ Text = title },
	}
end)


-- Keybindings
-- NB: On my laptop, the SUPER key is the CTRL key and CTRL is CMD key
config.keys = {
  -- Activate copy mode!
  { key = 'x', mods = 'CMD', action = wezterm.action.ActivateCopyMode },
  -- Cmd + n for new window
  {
    key = 'n',
    mods = 'CTRL',
    action = act.SpawnWindow,
  },
  -- Ctrl + n to open a new tab
  {
    key = 'n',
    mods = 'CMD',
    action = act{SpawnTab="CurrentPaneDomain"}
  },
  -- Ctrl + j to switch to left tab
  {
    key = 'j',
    mods = 'CMD',
    action = act.ActivateTabRelative(-1),
  },
    -- Ctrl + k to switch to right tab
  {
    key = 'k',
    mods = 'CMD',
    action = act.ActivateTabRelative(1),
  },
  -- Ctrl + Shift + j to scroll page up
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = act.ScrollByPage(-1),
  },
  -- Ctrl + Shift + k to scroll page down
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = act.ScrollByPage(1),
  },
  -- Ctrl + Shift + right arrow split horizontal
  {
    key = 'RightArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}},
  },
  -- Ctrl + Shift + down arrow split vertical
  {
    key = 'DownArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}},
  },
  -- RESIZE PANES - CTRL+ALT+ARROW KEYS
  {
    key = 'RightArrow',
    mods = 'CTRL|ALT',
    action = act.AdjustPaneSize { 'Right', 5 },
  },
  {
    key = 'LeftArrow',
    mods = 'CTRL|ALT',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|ALT',
    action = act.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'UpArrow',
    mods = 'CTRL|ALT',
    action = act.AdjustPaneSize { 'Up', 5 },
  },
  -- Minimise the terminal window
  { key = 'h', mods = 'CTRL|ALT', action = wezterm.action.Hide },
  -- Scroll by line
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(1) },
}

return config