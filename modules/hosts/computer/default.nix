{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.computer = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      # inputs.nixos-hardware.nixosModules.<your-model> # CHANGEME: see https://github.com/NixOS/nixos-hardware
      inputs.disko.nixosModules.disko

      # System
      # nvidia # CHANGEME: Uncomment if you have an Nvidia GPU
      audio
      bluetooth
      fonts
      systemd-boot # CHANGEME: Replace with lanzaboote to setup secure boot
      # kernel-hardening
      # usbguard

      # Desktop
      tuigreet
      autologin # Skip first TUIGreet login, use LUKS password to unlock the keyring
      gui

      # Programs
      tui
      steam
      # ollama # CHANGEME: Local LLMs, CUDA build (Nvidia only)

      # Host-specific
      ./_disko.nix
      ./_configuration.nix
    ];
  };
}
