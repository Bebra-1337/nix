{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    ida-pro
    zed-editor
    qtcreator
    antigravity-cli
    claude-code
    inputs.llm-agents.packages.${pkgs.system}.mimo-code
    jetbrains.clion
    onlyoffice-desktopeditors
    libreoffice-qt
  ];
}
