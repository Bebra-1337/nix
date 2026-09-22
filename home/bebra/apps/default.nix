{ ... }:

{
  # --- VPN (installed in bootstrap stage, kept here for completeness) ---

  imports = [
    ./browser.nix
    ./file-manager.nix
    ./gamedev.nix
    ./ide.nix
    ./cpp-toolchain.nix
    ./messaging.nix
    ./work.nix
    ./screen-capture.nix
    ./theming-tools.nix
    ./misc.nix
  ];
}
