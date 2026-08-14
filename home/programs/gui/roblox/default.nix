# Roblox development toolchain (for the ROXOR project and friends).
#
# Sync is handled by azul (github.com/Ransomwave/azul), a two-way Studio <-> disk
# sync where Studio is authoritative: it mirrors the DataModel to the filesystem
# with no project/meta files to maintain, unlike Rojo. azul-sync isn't in
# nixpkgs, so it's built here from its published git tag with buildNpmPackage.
#
#   azul    - two-way Studio <-> filesystem sync + Luau-LSP sourcemap
#   lune    - standalone Luau runtime (place-file scripting, e.g. rbxl snapshots)
#   stylua  - Luau/Lua formatter
#   selene  - Luau/Lua linter
#   git-lfs - stores large binary place files (*.rbxl / *.rbxlx) out of line
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

    # `npm run build` is a plain `tsc` compile into dist/; no native modules.
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
