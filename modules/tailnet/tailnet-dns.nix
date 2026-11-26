{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.tailnet-dns = {config, ...}: let
    address = tailnet.hosts.${config.networking.hostName};
  in {
    imports = [aspects.tailnet];

    # resolved already holds port 53 on localhost
    services.adguardhome = {
      enable = true;
      host = address;
      settings = {
        dns = {
          bind_hosts = [address];
          upstream_dns = ["https://1.1.1.1/dns-query"];
          fallback_dns = ["https://8.8.8.8/dns-query"];
        };
        filters = [
          {
            name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            id = 1;
            enabled = true;
          }
          {
            name = "AdAway Default Blocklist";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            id = 2;
            enabled = true;
          }
        ];
      };
    };
  };
}
