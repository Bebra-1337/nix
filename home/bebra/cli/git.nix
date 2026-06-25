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
