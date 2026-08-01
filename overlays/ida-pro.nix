final: prev: {
  ida-pro = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "ida-pro";
    version = "9.3";

    src = prev.requireFile {
      name = "ida-pro_93_x64linux.run";
      sha256 = "10hgnxnf3am90yd5ybwmlkz1pmm8vw8942ghwv54vmw4pgj3mm1f";
      message = ''
        Инсталлятор IDA Pro не найден в Nix-хранилище.
        Пожалуйста, добавьте его выполнением команды:
          nix-store --add-fixed sha256 "/home/bebra/Downloads/IDA Pro 9.3.260213/installers/ida-pro_93_x64linux.run"
      '';
    };

    keygenScript = ./keygen-v2_bgspa.py;

    nativeBuildInputs = with prev; [
      makeWrapper
      autoPatchelfHook
      python3
      perl
    ];

    dontUnpack = true;

    runtimeDependencies = with prev; [
      cairo
      dbus
      fontconfig
      freetype
      glib
      gtk3
      libdrm
      libGL
      libkrb5
      libsecret
      libunwind
      libxkbcommon
      openssl
      stdenv.cc.cc
      libice
      libsm
      libx11
      libxau
      libxcb
      libxext
      libxi
      libxrender
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libxcb-cursor
      zlib
      python312
    ];

    buildInputs = finalAttrs.runtimeDependencies;

    autoPatchelfIgnoreMissingDeps = [
      "libQt6Network.so.6"
      "libQt6EglFSDeviceIntegration.so.6"
      "libQt6WaylandEglClientHwIntegration.so.6"
      "libQt6WaylandCompositor.so.6"
      "libQt6WlShellIntegration.so.6"
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib $out/opt
      IDADIR=$out/opt/$pname-$version
      HOME=$out

      # 1. Распаковка/установка через системный динамический линкер Nix
      $(cat $NIX_CC/nix-support/dynamic-linker) $src \
        --mode unattended --prefix "$IDADIR"

      # 2. Применение патча RSA-модуля и генерация idapro.hexlic
      cd "$IDADIR"
      python3 $keygenScript --oneshot --name "bebra"

      # 3. Экспорт библиотек и пути поиска автопатча
      cp $IDADIR/libida.so $out/lib
      addAutoPatchelfSearchPath $IDADIR

      # 4. Обёртка бинарника IDA с автоматической инициализацией ~/.idapro
      wrapProgram $IDADIR/ida \
        --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms \
        --prefix LD_LIBRARY_PATH : "${prev.python312}/lib" \
        --set PYTHONHOME "${prev.python312}" \
        --run 'mkdir -p "$HOME/.idapro"' \
        --run 'if ! grep -q "Python3TargetDLL" "$HOME/.idapro/ida.reg" 2>/dev/null; then '"$IDADIR"'/idapyswitch -s '${prev.python312}'/lib/libpython3.12.so.1.0 >/dev/null 2>&1 || true; fi'

      ln -s $IDADIR/ida $out/bin/ida
      ln -s $IDADIR/ida $out/bin/ida64
      ln -s $IDADIR/idapyswitch $out/bin/idapyswitch

      patchelf --add-needed libcrypto.so $IDADIR/libida.so || true

      if [ -d $out/.local/share ]; then
        mv $out/.local/share $out
        rm -rf $out/.local
      fi

      runHook postInstall
    '';

    meta = {
      description = "IDA Pro 9.3 Disassembler and Decompiler";
      homepage = "https://hex-rays.com/ida-pro/";
      license = prev.lib.licenses.unfree;
      mainProgram = "ida";
      platforms = [ "x86_64-linux" ];
    };
  });
}
