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
  libglvnd,
}:
stdenv.mkDerivation rec {
  pname = "jopdf";
  version = "dynamic";

  src = fetchurl {
    url = "https://cdn.jopdf.com/download/jopdf/jopdf-linux-amd64_setup.deb";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [dpkg makeWrapper qt5.wrapQtAppsHook];
  buildInputs = [qt5.qtbase libsForQt5.qtstyleplugins libxcb libxkbcommon libx11 libxext fontconfig freetype libglvnd];

  dontAutoPatchelf = true;
  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Copiar los archivos binarios principales
    cp -r opt/jopdf $out/opt/

    # Crear el wrapper con las variables de entorno necesarias
    makeWrapper $out/opt/jopdf/JOPDF $out/bin/jopdf \
      --set QT_QPA_PLATFORMTHEME gtk3 \
      --set GTK_USE_PORTAL 1 \
      --prefix QT_PLUGIN_PATH : "${libsForQt5.qtstyleplugins}/lib/qt-5/plugins" \
      --prefix LD_LIBRARY_PATH : "$out/opt/jopdf/lib:${lib.makeLibraryPath [stdenv.cc.cc.lib libglvnd]}"

    # Extracción forzada del ícono: busca en las rutas comunes desempacadas o en el directorio opt
    if [ -f usr/share/pixmaps/jopdf.png ]; then
      cp usr/share/pixmaps/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
    elif [ -f usr/share/icons/hicolor/256x256/apps/jopdf.png ]; then
      cp usr/share/icons/hicolor/256x256/apps/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
    elif [ -f opt/jopdf/jopdf.png ]; then
      cp opt/jopdf/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png
    else
      # Si el paquete no tiene un PNG directo, creamos un fallback visual para que no salga la tuerca rota
      ln -s $out/opt/jopdf/jopdf.png $out/share/icons/hicolor/256x256/apps/jopdf.png || true
    fi

    # Lanzador .desktop bien estructurado
    cat > $out/share/applications/jopdf.desktop <<EOD
[Desktop Entry]
Name=JOPDF
Comment=JOPDF Free PDF Editor
Exec=$out/bin/jopdf
Icon=jopdf
Terminal=false
Type=Application
Categories=Office;Viewer;
StartupWMClass=JOPDF
EOD

    runHook postInstall
  '';

  postFixup = "wrapQtApp $out/bin/jopdf";

  meta = {
    description = "JOPDF Free PDF Editor";
    homepage = "https://www.jopdf.com";
    license = lib.licenses.unfree;
    maintainers = [];
    platforms = ["x86_64-linux"];
  };
}
