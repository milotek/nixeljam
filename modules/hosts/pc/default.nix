{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.pc = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      {
        networking.hostName = "pc";
        nixeljam = {
          username = "milotek";
          git = {
            name = "Milo Tekchandani";
            email = "milo@milotek.dev";
          };
          extraLocale = "en_US.UTF-8";
        };

        time.timeZone = "Europe/London";
        i18n.defaultLocale = "en_GB.UTF-8";
        services.xserver.xkb.layout = "gb";
      }

      # System
      nvidia
      audio
      bluetooth
      fonts
      systemd-boot
      tailscale

      # Desktop
      tuigreet
      niri
      noctalia
      desktop
      ghostty
      google-chrome
      nautilus
      loupe
      evince
      file-roller
      vlc
      obsidian
      vscode
      gnome-text-editor
      discord
      spotify
      obs-studio

      # Programs
      tui
      ai
      steam
      roblox
      docker
      tidyname

      # Host-specific
      ./_configuration.nix
    ];
  };
}
