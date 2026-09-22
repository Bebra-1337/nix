{ ... }:

{
  programs.ghidra = {
    enable = true;
    gdb = true;
  };

  programs.ccache.enable = true;
}
