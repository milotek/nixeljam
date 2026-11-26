{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.minipc = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      {
        networking.hostName = "minipc";
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
      audio
      bluetooth
      systemd-boot
      tailnet

      # Desktop
      tuigreet
      niri
      noctalia
      desktop
      ghostty
      google-chrome
      nautilus

      # Programs
      tui
      ai
      zellij
      tidyname
      docker

      # Services
      fail2ban
      copyparty
      navidrome
      slskd
      home-assistant
      tailnet-dns
      dashboard
      zellij-web
      site
      habits

      # Host-specific
      ./_configuration.nix
    ];
  };
}
