{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  glib,
  pango,
  cairo,
  gdk-pixbuf,
  graphene,
  openssl,
  makeDesktopItem,
}:
rustPlatform.buildRustPackage rec {
  pname = "kpm";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "ezequielgk";
    repo = "Kore-Package-Manager";
    rev = "v${version}";
    hash = "sha256-kKA9Xi81AkcAuvgl7nfrF28xBdyC5jqmXGmMz2rEGDQ=";
  };

  cargoHash = "sha256-Fkj8lRK6pRAvV+spRnpeleq5h5wSUlUiLrACB/l337A=";

  # Habilitar la feature de interfaz gráfica
  buildFeatures = ["gui"];

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    pango
    cairo
    gdk-pixbuf
    graphene
    openssl
  ];

  desktopItem = makeDesktopItem {
    name = "kpm-gui";
    exec = "kpm-gui";
    icon = "system-software-install";
    desktopName = "Kore Package Manager";
    genericName = "Package Manager";
    categories = ["System" "Settings"];
    comment = "A minimalist and universal program manager for Linux redesigned in Rust";
  };

  preBuild = ''
    export PKG_CONFIG_PATH="${gtk4.dev}/lib/pkgconfig:${libadwaita.dev}/lib/pkgconfig:${openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';

  postInstall = ''
    install -Dm644 ${desktopItem}/share/applications/* -t $out/share/applications/
  '';

  meta = with lib; {
    description = "A minimalist and universal program manager for Linux redesigned in Rust";
    homepage = "https://github.com/ezequielgk/Kore-Package-Manager";
    license = licenses.bsd3;
    mainProgram = "kpm";
    platforms = platforms.linux;
  };
}
