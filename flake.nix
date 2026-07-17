{
  description = "Mi repositorio personal de paquetes y módulos NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in {
      nixosModules = import ./modules;
      lib = import ./lib { inherit nixpkgs; };

      packages = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          jopdf = pkgs.callPackage ./pkgs/jopdf/package.nix {};
          default = self.packages.${system}.jopdf;
        }
      );

      # LA SOLUCIÓN REAL: Usamos "${self}/..." para fijar la ruta absoluta del repositorio
      overlays.default = final: prev: {
        jopdf = final.callPackage "${self}/pkgs/jopdf/package.nix" {};
        # Cuando agregues más paquetes en el futuro, los pones aquí usando ${self} igual:
        # otro-paquete = final.callPackage "${self}/pkgs/otro-paquete/package.nix" {};
      };
    };
}
