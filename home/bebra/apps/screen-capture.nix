{ pkgs, ... }:

{
  # --- Noctalia Screen Toolkit + bebra/snip (~/noctalia-snip) ---
  home.packages = with pkgs; [
    slurp
    grim
    hyprpicker
    (tesseract.override {
      enableLanguages = [
        "eng"
        "rus"
      ];
    })
    imagemagick
    zbar
    ffmpeg
    bc
    # gpu-screen-recorder — системный: programs.gpu-screen-recorder (modules/system/desktop-apps.nix)
    wl-screenrec
    translate-shell
    wayfreeze # snip: заморозка экрана под меню
  ];
}
