{aspects, ...}: {
  flake.modules.nixos.cli-tools.imports = [aspects.home-manager];
  flake.modules.nixos.cli-tools.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = with pkgs; [
          jless # A pager for JSON
          dua # Tool to conveniently learn about the disk usage of directories
          httpie # Command-line HTTP client, a user-friendly cURL replacement
          imagemagick # Image manipulation tool
          unstable.yt-dlp

          # Just cool
          fastfetch
          smassh # typing test, 10fastfinger like
        ];
      }
    )
  ];
}
