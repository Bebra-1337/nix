{ ... }:

{
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  # Secret Service для Noctalia (ключ шифрования clipboard/calendar) и др. приложений.
  # PAM разблокирует keyring "Login" паролем, введённым в noctalia-greeter (greetd).
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # SSH-агент уже задан через programs.ssh.startAgent (ssh.nix)
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.seahorse.enable = true; # GUI для управления keyring (Passwords and Keys)
  services.tumbler.enable = true;
}
