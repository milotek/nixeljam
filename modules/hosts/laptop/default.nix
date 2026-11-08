{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.h-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      inputs.nixos-hardware.nixosModules.omen-16-n0005ne
      inputs.disko.nixosModules.disko

      # System
      nvidia # CHANGEME: Remove this line if you don't have an Nvidia GPU
      audio
      bluetooth
      fonts
      lanzaboote # CHANGEME: Replace with systemd-boot if you don't want to setup secure boot
      kernel-hardening

      # Desktop
      tuigreet
      autologin # Skip first TUIGreet login, use LUKS password to unlock the keyring
      gui

      # Programs
      tui
      steam
      ollama

      # Host-specific
      ./_disko.nix
      ./_configuration.nix
    ];
  };
}
