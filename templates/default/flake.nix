{
  inputs = {
    nixeljam.url = "github:milotek/nixeljam";
    nixpkgs.follows = "nixeljam/nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixeljam,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # CHANGEME: pick what you want, see modules/bundles.nix and modules/ in nixeljam
      modules = with nixeljam.nixosModules; [
        base
        audio
        bluetooth
        fonts
        systemd-boot
        tuigreet
        gui
        tui
        steam

        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
