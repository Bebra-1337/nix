{ pkgs, ... }:

{
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

  # --- SSH Config ---
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_github";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_gitlab";
      };
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
}
