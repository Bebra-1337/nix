{ pkgs, ... }:

{
  home.packages = with pkgs; [
    godot
    godot-mono
    godot-mcp
    godot-export-templates-bin
  ];
}
