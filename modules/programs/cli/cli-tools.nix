{
  flake.modules.nixos.cli-tools.home-manager.sharedModules = [
    (
      {
        pkgs,
        pkgs-unstable,
        config,
        lib,
        ...
      }: {
        home.packages = with pkgs; [
          jless # A pager for JSON
          dua # Tool to conveniently learn about the disk usage of directories
          httpie # Command-line HTTP client, a user-friendly cURL replacement
          imagemagick # Image manipulation tool
          pkgs-unstable.yt-dlp

          # Just cool
          fastfetch
          smassh # typing test, 10fastfinger like
        ];
      }
    )
  ];
}
