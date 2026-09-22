{ flakeDir, ... }:

{
  programs.zsh.shellAliases = {
    # --- Navigation ---
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # --- ls / eza ---
    "ls" = "eza --icons=always --group-directories-first";
    "ll" = "eza -lh --icons=always --group-directories-first";
    "la" = "eza -lah --icons=always --group-directories-first";
    "lt" = "eza --tree --icons=always --level=2";
    "lta" = "eza --tree --icons=always --level=3 -a";

    # --- cat / bat ---
    "cat" = "bat --style=plain";
    "catp" = "bat --paging=never";

    # --- Git ---
    "g" = "git";
    "gs" = "git status";
    "ga" = "git add";
    "gc" = "git commit";
    "gp" = "git push";
    "gpl" = "git pull";
    "gd" = "git diff";
    "gl" = "git log --oneline --graph --decorate";
    "gco" = "git checkout";
    "gb" = "git branch";

    # --- Nix ---
    "nrs" = "sudo nixos-rebuild switch --flake ${flakeDir}#BEBRA-PC";
    "nrt" = "sudo nixos-rebuild test --flake ${flakeDir}#BEBRA-PC";
    "nrb" = "sudo nixos-rebuild boot --flake ${flakeDir}#BEBRA-PC";
    "nfu" = "nix flake update ${flakeDir}";
    "ngc" = "sudo nix-collect-garbage --delete-older-than 14d";
    "nsh" = "nix shell nixpkgs#";

    # --- C/C++/Qt ---
    "cmake-init" = "cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
    "cmake-dbg" = "cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
    "cbuild" = "cmake --build build --parallel $(nproc)";
    "cclean" = "rm -rf build";

    # --- System ---
    "df" = "df -h";
    "du" = "du -sh";
    "free" = "free -h";
    "top" = "btop";
    "ps" = "procs";
    "grep" = "grep --color=auto";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "mv" = "mv -i";
    "mkdir" = "mkdir -pv";
    "ports" = "ss -tulpn";

    # --- Apps ---
    "e" = "zed";
    "v" = "nvim";
    "dsh" = "node --expose-internals ~/.npm-global/bin/dsh";
    "dsh-tui" = "node --expose-internals ~/.npm-global/bin/dsh --profile tui";
  };
}
