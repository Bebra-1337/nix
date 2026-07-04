{ inputs, system, ... }:
final: prev: {
  bebrasoundcloud = final.stdenv.mkDerivation {
    pname = "bebrasoundcloud";
    version = "1.0.0";

    src = inputs.bebrasoundcloud.outPath;

    nativeBuildInputs = [
      final.makeWrapper
      final.copyDesktopItems
    ];

    buildInputs = [
      (final.python3.withPackages (ps: with ps; [
        pyside6
        pypresence
      ]))
    ];

    desktopItems = [
      (final.makeDesktopItem {
        name = "bebrasoundcloud";
        exec = "bebrasoundcloud";
        icon = "bebrasoundcloud";
        comment = "SoundCloud Desktop Player with Discord RPC";
        desktopName = "BebraSoundCloud";
        categories = [ "AudioVideo" "Audio" "Player" ];
      })
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/bebrasoundcloud $out/share/icons/hicolor/512x512/apps

      # Copy python script and icon
      cp soundcloud_rpc.py $out/share/bebrasoundcloud/
      cp soundcloud.jpg $out/share/icons/hicolor/512x512/apps/bebrasoundcloud.png

      # Create wrapper script
      makeWrapper ${
        (final.python3.withPackages (ps: with ps; [
          pyside6
          pypresence
        ]))
      }/bin/python3 $out/bin/bebrasoundcloud \
        --add-flags "$out/share/bebrasoundcloud/soundcloud_rpc.py"

      runHook postInstall
    '';

    meta = with final.lib; {
      description = "SoundCloud Desktop Client with Discord Rich Presence, MPRIS, and System Tray";
      license = licenses.mit;
      mainProgram = "bebrasoundcloud";
    };
  };
}
