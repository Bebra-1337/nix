{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "plugdev"
      "libvirtd"
      "tty"
      "ydotool"
    ];
  };

  programs.zsh.enable = true;
}
