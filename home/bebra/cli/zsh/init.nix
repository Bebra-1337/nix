{ ... }:

{
  programs.zsh.initContent = ''
    # NPM Global packages PATH
    export PATH="$HOME/.npm-global/bin:$PATH"

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
    #export QML2_IMPORT_PATH="$HOME/.local/lib/qml"

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
}
