{ pkgs, ...}:
{
  home.packages = with pkgs; [
    wezterm
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;

  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;

    extraConfig = ''
local wezterm = require 'wezterm'
local act = wezterm.action -- shorthand for wezterm.action
local config = wezterm.config_builder()

--config.front_end = 'Software'

-- Workspace:
--config.default_domain = 'WSL:Ubuntu-22.04'

-- Windows:
config.initial_cols = 120
config.initial_rows = 28
--config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Font size and color scheme:
config.font = wezterm.font('MesloLGS Nerd Font')
config.font_shaper = 'Harfbuzz'
config.font_size = 12
config.color_scheme = 'Tokyo Night'

-- Tab bar:
-- config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.max_fps = 120

config.keys = {
  {
    key = 'w',
    mods = 'CTRL|SHIFT|ALT',
    action = act.CloseCurrentPane { confirm = true },
  },
  {
    key = 'T',
    mods = 'CTRL|SHIFT|ALT',
    action = act.TogglePaneZoomState,
  },

  -- **Add these lines to disable/remap WezTerm's internal multiplexing actions:**
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnWindow }, -- New Window (or New Tab if not explicit window)

  -- Disable default keybindings for creating new tabs/windows/panes
  -- { key = 't', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment }, -- New Tab
  { key = '%', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment }, -- Split Pane Horizontal
  { key = '"', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment }, -- Split Pane Vertical

  -- You might also want to disable or remap pane navigation if it conflicts with tmux's C-a + arrow keys
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment },

  -- If you want to use these keys for other WezTerm actions, replace `DisableDefaultAssignment`
  -- with your desired action, or simply don't include the line if you want to leave WezTerm's
  -- default behavior for those keys to clash with tmux.
  -- For example, if you wanted Ctrl-Shift-T to open a *new WezTerm window* instead of a new tab:
  -- { key = 'T', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
}


-- -- Add/modify the mouse_bindings section:
-- config.mouse_bindings = {
--   -- This is the default Left click binding.
--   -- The important part is `action = wezterm.action.CompleteSelection 'Clipboard'`
--   {
--     event = { Up = { streak = 1, button = 'Left' } },
--     mods = 'NONE',
--     action = act.CompleteSelection 'Clipboard',
--   },
--   -- You can add this if you want Middle click to paste from clipboard
--   -- {
--   --   event = { Up = { streak = 1, button = 'Middle' } },
--   --   mods = 'NONE',
--   --   action = act.PasteFrom 'PrimarySelection', -- Or 'Clipboard' if you prefer
--   -- },
-- }

return config
    '';
  };
}
