{aspects, ...}: {
  flake.modules.nixos.networking = {
    imports = [aspects.common];

    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;

    environment.persistence."/persist".directories = [
      "/etc/NetworkManager/system-connections" # Wifi connections, VPN
    ];
  };
}
