# VLC: video player
{
  flake.modules.nixos.vlc.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.vlc];
      }
    )
  ];
}
