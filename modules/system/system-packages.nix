{ pkgs, ... }:

{
  # gvfs и tumbler устанавливаются автоматически через services.*.enable
  environment.systemPackages = with pkgs; [
    wget
    curl
    vim
    file
    ffmpegthumbnailer
    libgsf
    bluez-tools
    ydotool
  ];
}
