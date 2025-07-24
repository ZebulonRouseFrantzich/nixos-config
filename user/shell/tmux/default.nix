{ pkgs, ...}:
{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;
    terminal = "wezterm";

    historyLimit = 20000;
    prefix = "C-a";
    mouse = true;
    escapeTime = 0;
    baseIndex = 0;
    focusEvents = true;
    keyMode = "vi";
    aggressiveResize = true;
    
    extraConfig = ''
      # automatically renumber tmux windows
      set -g renumber-windows on

      ##########################
      #### General Settings ####
      ##########################

      set -g set-clipboard on
      setw -g pane-base-index 0
      set-option -g set-titles on
      set -g detach-on-destroy off
      set -g status-keys vi
      
      # disabled activity monitoring
      setw -g monitor-activity off
      set -g visual-activity off

      ######################
      #### Key Bindings ####
      ######################

      # keep CWD when opening new window
      unbind c
      bind c new-window -c "#{pane_current_path}"

      # reload config file
      bind r source-file ~/.tmux.conf \; display "Config Reloaded!"

      # split window and fix path for tmux 1.9
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # settings to make copy-mode more vim-like
      unbind [
      bind Escape copy-mode
      unbind p
      bind p paste-buffer
      bind -T copy-mode-vi v send -X begin-selection

      ########################
      #### Display Popups ####
      ########################

      bind C-g display-popup \
        -d "#{pane_current_path}" \
        -w 80% \
        -h 80% \
        -E "lazygit"
      bind C-n display-popup -E 'bash -i -c "read -p \"Session name: \" name; tmux new-session -d -s \$name && tmux switch-client -t \$name"'
      bind C-t display-popup \
        -d "#{pane_current_path}" \
        -w 75% \
        -h 75% \
        -E "bash"

      ####################
      #### Status Bar ####
      ####################

      set -g status on # Ensure status bar is on
      set -g status-position top

      # Status bar styling
      set -g status-style "fg=white,bg=#36013F" # Default status bar colors (dark gray background)
      set -g status-left-length 90             # Sufficient length for left segment
      set -g status-right-length 90            # Sufficient length for right segment
    ''; 
  };
}
