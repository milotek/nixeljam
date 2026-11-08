# Groups of aspects, so hosts list features by area
# Importing a bundle and one of its members is fine: aspects are deduplicated (flake/parts.nix)
{aspects, ...}: {
  flake.modules.nixos = with aspects; {
    # System base, on every host
    base.imports = [
      common
      theme
      home-manager
      nix
      users
      utils
    ];

    # Terminal environment, on every host
    tui.imports = [
      shell
      git
      btop
      cli-tools
      tldr
      nix-utils
      nixy
      nvim
      dev
    ];

    # Self-hosted services exposed through the Cloudflare tunnel (modules/server)
    homelab.imports = [
      ssh
      firewall
      fail2ban
      cloudflared
      adguardhome
      arr
      bentopdf
      cyberchef
      mazanoke
      gitea
      miniflux
      uptime-kuma
      glance
    ];

    # Graphical session: niri + noctalia + desktop, gui apps
    gui.imports = [
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
      onlyoffice
      signal
      vscode
      gnome-text-editor
      discord
      spotify
      obs-studio
    ];
  };
}
