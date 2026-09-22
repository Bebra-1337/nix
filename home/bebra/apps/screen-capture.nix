{ pkgs, ... }:

{
  # --- Noctalia Screen Toolkit ---
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
    gpu-screen-recorder
    wl-screenrec
    translate-shell
  ];
}
