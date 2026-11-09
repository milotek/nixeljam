{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.minipc = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      base

      # System
      audio
      bluetooth
      fonts
      systemd-boot
      ydotool
      tailscale
      ssh

      # Services, reached over the tailnet; the VPS's caddy proxies them over TLS
      adguardhome
      fail2ban
      copyparty
      navidrome
      slskd
      home-assistant
      glance
      zellij-web
      pelican
      site
      habits

      # Desktop
      tuigreet
      niri
      noctalia
      desktop

      # Programs (lighter than pc - no creative/gaming/media tooling)
      google-chrome
      vlc
      obsidian
      gnome-text-editor
      ticktick
      pinta
      onlyoffice
      blanket
      signal
      ghostty
      zellij
      nvim
      shell
      git
      git-signing
      njam
      nix-utils
      ai
      tidyname
      cli-tools
      dev

      # Host-specific
      ./_configuration.nix
    ];
  };
}
