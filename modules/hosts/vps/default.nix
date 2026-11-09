{
  aspects,
  inputs,
  ...
}: {
  flake.nixosConfigurations.vps = inputs.nixpkgs.lib.nixosSystem {
    modules = with aspects; [
      common
      theme
      home-manager
      nix
      users
      user-password
      inputs.disko.nixosModules.disko

      tailscale
      ssh
      fail2ban
      caddy
      game-relay

      shell
      zellij
      git
      nix-utils

      ./_configuration.nix
    ];
  };
}
