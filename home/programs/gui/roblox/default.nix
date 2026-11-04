{pkgs, ...}: let
  azul = pkgs.buildNpmPackage rec {
    pname = "azul-sync";
    version = "1.6.0";

    src = pkgs.fetchFromGitHub {
      owner = "Ransomwave";
      repo = "azul";
      rev = "v${version}";
      hash = "sha256-BTaO0t3PVPgv00wnHqubkggQ+vS7oc25lFUhC1TWf9M=";
    };

    npmDepsHash = "sha256-pQ5ha8lUHZZyG0CvNHD7oihKlQFsyLXaIxi9UpQ2tCo=";

    dontNpmBuild = false;

    meta = {
      description = "Two-way Roblox Studio <-> filesystem sync with Luau-LSP support";
      homepage = "https://github.com/Ransomwave/azul";
      license = pkgs.lib.licenses.mit;
      mainProgram = "azul";
    };
  };
in {
  home.packages =
    [azul]
    ++ (with pkgs; [
      lune
      stylua
      selene
      git-lfs
    ]);
}
