{ ... }:

{
  programs.ghidra = {
    enable = true;
    gdb = true;
  };

  programs.ccache.enable = true;
  # Модуль ccache ставит setgid-обёртку nix-ccache поверх perl-скрипта, а новая
  # проверка ensure-wrapper-integrity в nixpkgs валит сборку на не-ELF источниках.
  # Обёртка нужна только для `nix-ccache --show-stats/--clear` — отключаем её.
  security.wrappers.nix-ccache.enable = false;
}
