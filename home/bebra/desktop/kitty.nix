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

      # Colors — managed by Matugen templates
      # Matugen will write to ~/.config/kitty/current-theme.conf
    };

    extraConfig = ''
      # Include Matugen-generated theme
      include current-theme.conf
    '';

    keybindings = {
      "ctrl+c"       = "copy_or_interrupt";
      "ctrl+с"       = "copy_or_interrupt"; # Russian с
      "ctrl+v"       = "paste_from_clipboard";
      "ctrl+м"       = "paste_from_clipboard"; # Russian м
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+w" = "close_tab";
      "ctrl+tab"     = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+equal"   = "increase_font_size";
      "ctrl+minus"   = "decrease_font_size";
      "ctrl+0"       = "restore_font_size";

      # Исправление горячих клавиш Ctrl в русской раскладке (отправляем ASCII-коды управления)
      "ctrl+я" = "send_text all \\x1a"; # Ctrl+Z
      "ctrl+ф" = "send_text all \\x01"; # Ctrl+A
      "ctrl+и" = "send_text all \\x02"; # Ctrl+B
      "ctrl+в" = "send_text all \\x04"; # Ctrl+D
      "ctrl+у" = "send_text all \\x05"; # Ctrl+E
      "ctrl+а" = "send_text all \\x06"; # Ctrl+F
      "ctrl+п" = "send_text all \\x07"; # Ctrl+G
      "ctrl+р" = "send_text all \\x08"; # Ctrl+H
      "ctrl+ш" = "send_text all \\x09"; # Ctrl+I
      "ctrl+о" = "send_text all \\x0a"; # Ctrl+J
      "ctrl+л" = "send_text all \\x0b"; # Ctrl+K
      "ctrl+д" = "send_text all \\x0c"; # Ctrl+L
      "ctrl+ь" = "send_text all \\x0d"; # Ctrl+M
      "ctrl+т" = "send_text all \\x0e"; # Ctrl+N
      "ctrl+щ" = "send_text all \\x0f"; # Ctrl+O
      "ctrl+з" = "send_text all \\x10"; # Ctrl+P
      "ctrl+й" = "send_text all \\x11"; # Ctrl+Q
      "ctrl+к" = "send_text all \\x12"; # Ctrl+R
      "ctrl+ы" = "send_text all \\x13"; # Ctrl+S
      "ctrl+е" = "send_text all \\x14"; # Ctrl+T
      "ctrl+г" = "send_text all \\x15"; # Ctrl+U
      "ctrl+ц" = "send_text all \\x17"; # Ctrl+W
      "ctrl+ч" = "send_text all \\x18"; # Ctrl+X
      "ctrl+н" = "send_text all \\x19"; # Ctrl+Y
    };
  };
}
