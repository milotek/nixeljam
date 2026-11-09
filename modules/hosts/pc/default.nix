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
      grub
      ydotool
      usbguard
      tailscale
      ssh

      # Desktop
      tuigreet
      niri
      noctalia
      desktop
      gpu-screen-recorder
      remote-desktop

      # Programs
      gaming
      docker
      ollama
      google-chrome
      proton
      spotify
      thunar
      blender
      godot
      roblox
      vlc
      obsidian
      gnome-text-editor
      ticktick
      pinta
      onlyoffice
      blanket
      signal
      ghostty
      nvim
      shell
      git
      git-signing
      njam
      nix-utils
      tidyname
      spotatui
      navi
      wikiman
      opencode
      rclone
      ai
      cli-tools
      cybersecurity
      dev

      # Host-specific
      ./_configuration.nix
    ];
  };
}
