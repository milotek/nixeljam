{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.pc = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

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
      replay

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
