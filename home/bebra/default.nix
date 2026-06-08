{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./hyprland.nix
    ./kitty.nix
    ./zsh.nix
    ./apps.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.05";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # --- Noctalia shell ---
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        density = "compact";
        showCapsule = true;
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "ActiveWindow"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "SystemMonitor"; }
            { id = "Tray"; }
            { id = "Volume"; }
            { id = "NotificationHistory"; }
            { id = "ControlCenter"; }
            {
              id = "Clock";
              useMonospacedFont = true;
            }
          ];
        };
      };
      colorSchemes = {
        useWallpaperColors = true;  # генерировать цвета из обоев
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        generationMethod = "tonal-spot";
        syncGsettings = true;
      };
      general = {
        telemetryEnabled = false;
        enableBlurBehind = true;
        enableShadows = true;
        showChangelogOnStartup = false;
        lockOnSuspend = true;
      };
      location = {
        name = "Moscow, Russia";
        use12hourFormat = false;
      };
      appLauncher = {
        terminalCommand = "kitty";
        sortByMostUsed = true;
        enableClipboardHistory = true;
      };
    };
  };

  # --- Git ---
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Romanov Bebra";
      user.email = "bebra@bebralegendick.ru";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "zed --wait";
    };
  };

  # --- direnv + nix-direnv ---
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # --- nix-index (nix-locate to find packages by file) ---
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- Session variables ---
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERMINAL = "kitty";
    BROWSER = "vivaldi";
  };

  # --- GTK theming ---
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # --- XDG dirs ---
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
