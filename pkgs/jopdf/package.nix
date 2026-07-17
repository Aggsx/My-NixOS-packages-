{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  dpkg,
  qt5,
  libsForQt5,
  libxcb,
  libxkbcommon,
  libx11,
  libxext,
  fontconfig,
  freetype,
  zlib,
  cups,
  libglvnd,
  mesa,
  e2fsprogs,
  libgpg-error,
}:
stdenv.mkDerivation rec {
  pname = "jopdf";
  version = "2.2.0";

  src = fetchurl {
    url = "https://cdn.jopdf.com/download/jopdf/jopdf-linux-amd64_setup.deb";
    hash = "sha256-G993GJOUOh6WsbXcxir1MKrsUFmqCfqA4BtuAyKMsyc=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    libsForQt5.qtstyleplugins
    libxcb
    libxkbcommon
    libx11
    libxext
    fontconfig
    freetype
    zlib
    cups
    libglvnd
    mesa
    e2fsprogs
    libgpg-error
  ];

  dontAutoPatchelf = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
        mkdir -p $out/opt
        cp -r opt/jopdf $out/opt/

        mkdir -p $out/bin

        makeWrapper \
          $out/opt/jopdf/JOPDF \
          $out/bin/jopdf \
          --set QT_QPA_PLATFORMTHEME gtk3 \
          --set GTK_USE_PORTAL 1 \
          --prefix QT_PLUGIN_PATH : "${libsForQt5.qtstyleplugins}/lib/qt-5/plugins" \
          --prefix LD_LIBRARY_PATH : "$out/opt/jopdf/lib:${lib.makeLibraryPath [
      stdenv.cc.cc.lib
      libglvnd
      mesa
      zlib
      libx11
      e2fsprogs
      libgpg-error
    ]}"

        mkdir -p $out/share/applications

        cat > $out/share/applications/jopdf.desktop <<EOF
    [Desktop Entry]
    Name=JOPDF
    Comment=JOPDF Free PDF Editor, Converter and Reader
    Exec=jopdf
    Icon=jopdf
    Terminal=false
    Type=Application
    Categories=Office;Viewer;
    StartupWMClass=JOPDF
    EOF

        # ---- AQUÍ ESTÁ LA LOGICA DEL ICONO QUE SÍ FUNCIONABA ----
        mkdir -p $out/share/icons/hicolor/256x256/apps

        if [ -f usr/share/pixmaps/jopdf.png ]; then
          cp usr/share/pixmaps/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
        elif [ -f usr/share/icons/hicolor/256x256/apps/jopdf.png ]; then
          cp usr/share/icons/hicolor/256x256/apps/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
        elif [ -f opt/jopdf/jopdf.png ]; then
          cp opt/jopdf/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
        else
          ln -s $out/opt/jopdf/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png || true
        fi
        # --------------------------------------------------------
  '';

  postFixup = ''
    wrapQtApp $out/bin/jopdf
  '';

  meta = {
    description = "JOPDF Free PDF Editor, Converter and Reader";
    homepage = "https://www.jopdf.com";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "jopdf";
  };
}
