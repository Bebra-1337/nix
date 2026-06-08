{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    # Font
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };

    settings = {
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Appearance
      window_padding_width = 12;
      hide_window_decorations = true;
      background_opacity = "0.92";
      background_blur = 32;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = "15.0";

      # Scrollback
      scrollback_lines = 10000;

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Bell
      enable_audio_bell = false;
      visual_bell_duration = "0.0";

      # URLs
      url_style = "curly";
      open_url_with = "vivaldi";

      # Wayland
      linux_display_server = "wayland";

      # Shell integration
      shell_integration = "enabled";

      # Colors — managed by Noctalia templates
      # Noctalia will write to ~/.config/kitty/current-theme.conf
    };

    extraConfig = ''
      # Include Noctalia-generated theme
      include current-theme.conf
    '';

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+w" = "close_tab";
      "ctrl+tab"     = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+equal"   = "increase_font_size";
      "ctrl+minus"   = "decrease_font_size";
      "ctrl+0"       = "restore_font_size";
    };
  };
}
