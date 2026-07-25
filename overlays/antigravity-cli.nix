final: prev: {
  antigravity-cli =
    let
      version = "1.0.12";
      buildId = "6156052174077952";
      wholeVersion = "${version}-${buildId}";
      throwSystem = throw "Unsupported system: ${final.stdenvNoCC.hostPlatform.system}";
      sourceData = {
        x86_64-linux = final.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-x64/cli_linux_x64.tar.gz";
          hash = "sha256-fjB132jrrViqHPQiMenYuDvyiVtbBYqxc2sLY4PHUAg=";
        };
        aarch64-linux = final.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-arm/cli_linux_arm64.tar.gz";
          hash = "sha256-oDZ+WHWsG4imwLFjyG69XRPJvvkH9EaaZRb/aQIb8tQ=";
        };
        aarch64-darwin = final.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/darwin-arm/cli_mac_arm64.tar.gz";
          hash = "sha256-U/cwihF/cP5+7KSmkAToI5yOoYydguR5ZrKQMytpuCk=";
        };
      };
    in
    final.stdenvNoCC.mkDerivation {
      pname = "antigravity-cli";
      inherit version;
      strictDeps = true;
      __structuredAttrs = true;
      src = sourceData.${final.stdenvNoCC.hostPlatform.system} or throwSystem;
      sourceRoot = ".";
      nativeBuildInputs = final.lib.optionals final.stdenvNoCC.hostPlatform.isElf [ final.autoPatchelfHook ];
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 antigravity $out/bin/agy
        runHook postInstall
      '';
      nativeInstallCheckInputs = [ final.versionCheckHook ];
      doInstallCheck = true;
      meta = {
        description = "Google's Go-based terminal user interface (TUI) agent client";
        homepage = "https://antigravity.google";
        license = final.lib.licenses.unfree;
        platforms = final.lib.attrNames sourceData;
        mainProgram = "agy";
        sourceProvenance = with final.lib.sourceTypes; [ binaryNativeCode ];
      };
    };
}
