{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          top = 1;
          left = 2;
          right = 2;
        };
      };
      display = {
        separator = " 󰧞 ";
        color = {
          keys = "cyan";
          title = "magenta";
        };
      };
      modules = [
        "title"
        {
          type = "custom";
          format = "───────────────────────────────";
        }
        {
          type = "os";
          key = "  󱄅 os  ";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "  󰽘 kern";
          keyColor = "blue";
        }
        {
          type = "uptime";
          key = "  󱎫 upt ";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = "  󰏖 pkgs";
          keyColor = "cyan";
          format = "{nix-all} (nix), {flatpak-all} (flatpak)";
        }
        {
          type = "shell";
          key = "  󰞷 sh  ";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = "  󰆍 term";
          keyColor = "cyan";
        }
        {
          type = "cpu";
          key = "  󰻠 cpu ";
          keyColor = "magenta";
        }
        {
          type = "gpu";
          key = "  󰢮 gpu ";
          keyColor = "magenta";
        }
        {
          type = "memory";
          key = "  󰍛 mem ";
          keyColor = "magenta";
        }
        {
          type = "custom";
          format = "───────────────────────────────";
        }
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
