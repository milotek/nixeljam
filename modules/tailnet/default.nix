{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.lib.tailnet = {
    domain = "tek.rip";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev";
    hosts = {
      minipc = "100.85.180.11";
      vps = "100.117.236.50";
      shitbox = "100.108.183.51";
    };
  };

  flake.modules.nixos.tailnet = {config, ...}: let
    username = config.nixeljam.username;
  in {
    imports = [
      aspects.tailscale
      aspects.ssh
      aspects.secrets
    ];

    # Without resolved, tailscaled takes over all of resolv.conf
    services.resolved.enable = true;

    users.users.${username}.openssh.authorizedKeys.keys = [tailnet.key];

    sops.secrets.ssh-key = {
      path = "${config.users.users.${username}.home}/.ssh/id_ed25519";
      owner = username;
    };

    # The vps once banned minipc for its ssh retries
    services.fail2ban.ignoreIP = ["100.64.0.0/10"];
  };
}
