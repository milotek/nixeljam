# VLC: media player, default for audio and video
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.vlc = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.vlc];

        xdg.mimeApps = mime.defaultFor "vlc.desktop" (mime.types.audio ++ mime.types.video);
      })
    ];
  };
}
