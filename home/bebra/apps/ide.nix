{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    ida-pro
    # реверс: uv — для ida-pro-mcp/idalib, frida — динамика
    uv
    frida-tools
    zed-editor
    qtcreator
    antigravity-cli
    claude-code
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mimo-code
    jetbrains.clion
    onlyoffice-desktopeditors
    libreoffice-qt
  ];

  # стабильный путь к IDA для idalib (~/.idapro/ida-config.json), не меняется при обновлении
  home.file.".local/share/ida-pro".source = "${pkgs.ida-pro}/opt/ida-pro-${pkgs.ida-pro.version}";
}
