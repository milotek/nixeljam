# Spotify: music player
{aspects, ...}: {
  flake.modules.nixos.spotify = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.spotify];

        home.persistence."/persist".directories = [
          ".config/spotify"
        ];
      })
    ];
  };
}
