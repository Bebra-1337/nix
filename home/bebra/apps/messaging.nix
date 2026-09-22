{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (discord.override {
      withVencord = true;
      withOpenASAR = false; # faster app.asar replacement
    })
  ];
}
