{
  lib,
  python3Packages,
  wrapGAppsHook3,
  qt6,
  gobject-introspection,
  gtk3,
  libappindicator-gtk3,
  libusb1,
  xvfb-run,
}:

python3Packages.buildPythonApplication {
  pname = "gigamate";
  version = "4.4.3";
  pyproject = true;

  src = ./.;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pyusb
    python3Packages.evdev
    python3Packages.pyqt6
    python3Packages.pygobject3
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
    qt6.wrapQtAppsHook
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    qt6.qtbase
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  postInstall = ''
    install -Dm644 data/gigamate.desktop -t $out/share/applications/
    install -Dm644 data/gigamate-center.desktop -t $out/share/applications/

    install -Dm644 data/gigamate*.svg -t $out/share/icons/hicolor/scalable/apps/
    install -Dm644 data/checkbox-checked.svg -t $out/share/icons/hicolor/scalable/apps/

    install -Dm644 data/70-gigamate.rules -t $out/lib/udev/rules.d/
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      "''${qtWrapperArgs[@]}"
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libusb1 ]}
    )
  '';

  nativeCheckInputs = [
    python3Packages.pytest
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    export QT_QPA_PLATFORM=offscreen
    xvfb-run -s '-screen 0 800x600x24' pytest --basetemp=/tmp/pt
    runHook postCheck
  '';

  meta = {
    description = "Gigabyte laptop management for Linux";
    homepage = "https://github.com/goodeesh/GigaMate";
    license = lib.licenses.mit;
    mainProgram = "gigamate";
    platforms = [ "x86_64-linux" ];
  };
}
