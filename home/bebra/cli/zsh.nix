{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    
    dotDir = "${config.xdg.configHome}/zsh"; # абсолютный путь (относительные deprecated в HM)
    autocd = true;
    enableCompletion = true;

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
    ];

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      # --- Navigation ---
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";

      # --- ls / eza ---
      "ls"   = "eza --icons=always --group-directories-first";
      "ll"   = "eza -lh --icons=always --group-directories-first";
      "la"   = "eza -lah --icons=always --group-directories-first";
      "lt"   = "eza --tree --icons=always --level=2";
      "lta"  = "eza --tree --icons=always --level=3 -a";

      # --- cat / bat ---
      "cat"  = "bat --style=plain";
      "catp" = "bat --paging=never";

      # --- Git ---
      "g"    = "git";
      "gs"   = "git status";
      "ga"   = "git add";
      "gc"   = "git commit";
      "gp"   = "git push";
      "gpl"  = "git pull";
      "gd"   = "git diff";
      "gl"   = "git log --oneline --graph --decorate";
      "gco"  = "git checkout";
      "gb"   = "git branch";

      # --- Nix ---
      "nrs"  = "sudo nixos-rebuild switch --flake /home/bebra/nix#BEBRA-PC";
      "nrt"  = "sudo nixos-rebuild test --flake /home/bebra/nix#BEBRA-PC";
      "nrb"  = "sudo nixos-rebuild boot --flake /home/bebra/nix#BEBRA-PC";
      "nfu"  = "nix flake update /home/bebra/nix";
      "ngc"  = "sudo nix-collect-garbage --delete-older-than 14d";
      "nsh"  = "nix shell nixpkgs#";

      # --- C/C++/Qt ---
      "cmake-init" = "cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
      "cmake-dbg"  = "cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
      "cbuild"     = "cmake --build build --parallel $(nproc)";
      "cclean"     = "rm -rf build";

      # --- System ---
      "df"   = "df -h";
      "du"   = "du -sh";
      "free" = "free -h";
      "top"  = "btop";
      "ps"   = "procs";
      "grep" = "grep --color=auto";
      "rm"   = "rm -i";
      "cp"   = "cp -i";
      "mv"   = "mv -i";
      "mkdir" = "mkdir -pv";
      "ports" = "ss -tulpn";

      # --- Apps ---
      "e"    = "zed";
      "v"    = "nvim";
    };

    initContent = ''
      # zoxide (smarter cd)
      eval "$(zoxide init zsh)"

      # Привязка стрелочек для умного поиска по истории (history-substring-search)
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^[OA' history-substring-search-up
      bindkey '^[OB' history-substring-search-down

      # Ctrl + стрелочки для навигации по словам и гибкого автодополнения (по одному слову)
      bindkey '^[[1;5C' forward-word      # Ctrl + Стрелка вправо (принять одно слово автодополнения)
      bindkey '^[[1;5D' backward-word     # Ctrl + Стрелка влево (перейти на слово назад)

      # Ctrl+Z для отмены ввода (undo) в интерактивной строке
      bindkey '^Z' undo

      # fzf настройки управляются через programs.fzf ниже

      # --- fzf-tab configuration ---
      # Отключаем стандартное меню автодополнения Zsh
      zstyle ':completion:*' menu no
      # Группируем результаты автодополнения по категориям
      zstyle ':completion:*:descriptions' format '[%d]'
      # Интерактивный предпросмотр файлов через bat и папок через eza
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza -1 --color=always --icons $realpath'
      # Интерактивное дерево процессов для команды kill
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --forest -p $group'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'

      # Разноцветные man-страницы (красивый просмотр документации)
      export LESS_TERMCAP_mb=$'\e[1;31m'      # blinking
      export LESS_TERMCAP_md=$'\e[1;36m'      # bold (cyan)
      export LESS_TERMCAP_me=$'\e[0m'         # end bold/blink
      export LESS_TERMCAP_so=$'\e[01;33m'     # standout (yellow/black)
      export LESS_TERMCAP_se=$'\e[0m'         # end standout
      export LESS_TERMCAP_us=$'\e[1;4;32m'    # underline (green)
      export LESS_TERMCAP_ue=$'\e[0m'         # end underline

      # Запуск fastfetch при открытии нового терминала (только в интерактивной сессии)
      if [[ -o interactive ]]; then
        fastfetch --logo-width 18 --logo-padding 3 --logo nixos_small
      fi

      # C/C++ dev env
      export CC=gcc
      export CXX=g++
      export CMAKE_GENERATOR=Ninja

      # Qt/QML dev
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QML2_IMPORT_PATH="$HOME/.local/lib/qml"

      # Запуск Qt Creator в фоне с отвязкой от терминала (чтобы консоль можно было закрыть)
      qtc() {
        qtcreator "''${@:-.}" &> /dev/null &!
      }

      # Динамическое слияние конфига starship с палитрой цветов Noctalia
      if [ -f "$HOME/.config/starship.toml" ]; then
        mkdir -p "$HOME/.cache/starship"
        cat "$HOME/.config/starship.toml" > "$HOME/.cache/starship/config.toml"
        if [ -f "$HOME/.cache/noctalia/starship-palette.toml" ]; then
          cat "$HOME/.cache/noctalia/starship-palette.toml" >> "$HOME/.cache/starship/config.toml"
        fi
        export STARSHIP_CONFIG="$HOME/.cache/starship/config.toml"
      fi
    '';
  };

  # --- Starship prompt — native TOML config (цвета управляются Noctalia) ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Указываем активную палитру (файл с цветами подключается динамически ниже)
    settings = builtins.fromTOML (builtins.readFile ../../../dotfiles/starship.toml) // {
      palette = "noctalia";
    };
  };

  # --- Tools used in aliases ---
  home.packages = with pkgs; [
    eza
    bat
    fd
    zoxide
    ripgrep
    btop
    procs
    jq
    tokei       # code stats
    hyperfine   # benchmarking
  ];

  # --- FZF Integration ---
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidget.command = "fd --type f --hidden --follow --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --follow --exclude .git";
  };
}
