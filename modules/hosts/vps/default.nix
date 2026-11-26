{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.vps = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      {
        networking.hostName = "vps";
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

      inputs.disko.nixosModules.disko

      # System
      systemd-boot
      tailnet

      # Programs
      shell
      git
      nix-utils
      btop
      zellij

      # Services
      fail2ban
      caddy

      # Host-specific
      ./_disko.nix
      ./_configuration.nix
    ];
  };
}
