# Spotify: music player
{
  flake.modules.nixos.spotify.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.spotify];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/spotify"
          ];
        };
      }
    )
  ];
}
