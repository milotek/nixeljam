# Spotify: music player
{aspects, ...}: {
  flake.modules.nixos.spotify.imports = [aspects.home-manager];
  flake.modules.nixos.spotify.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.spotify];

        home.persistence."/persist" = {
          directories = [
            ".config/spotify"
          ];
        };
      }
    )
  ];
}
