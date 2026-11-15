{inputs, ...}: {
  flake.modules.nixos.roblox = {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

    services.flatpak = {
      enable = true;
      packages = ["org.vinegarhq.Sober"];
    };

    home-manager.sharedModules = [
      (
        {pkgs, ...}: let
          azul = pkgs.buildNpmPackage rec {
            pname = "azul";
            version = "1.6.0";
            src = pkgs.fetchFromGitHub {
              owner = "Ransomwave";
              repo = "azul";
              rev = "v${version}";
              hash = "sha256-BTaO0t3PVPgv00wnHqubkggQ+vS7oc25lFUhC1TWf9M=";
            };
            npmDepsHash = "sha256-pQ5ha8lUHZZyG0CvNHD7oihKlQFsyLXaIxi9UpQ2tCo=";
            meta.mainProgram = "azul";
          };
        in {
          home.packages = [
            azul
            pkgs.vinegar
            pkgs.lune
          ];
        }
      )
    ];
  };
}
