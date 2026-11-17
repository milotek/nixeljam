{aspects, ...}: {
  flake.modules.nixos.dev.imports = [aspects.home-manager];
  flake.modules.nixos.dev.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home = {
          packages = with pkgs.unstable;
            [
              go
              bun
            ]
            ++ (with pkgs; [
              nodejs
              air
              duckdb
              python3
              jq
              nix-prefetch-github
              rsync
            ]);

          sessionPath = ["$HOME/.local/share/go/bin"];
          sessionVariables.GOPATH = "$HOME/.local/share/go";
        };
      }
    )
  ];
}
