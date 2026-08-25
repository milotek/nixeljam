# Publishes minipc's Minecraft server on the VPS's public IP.
#
# minipc has no public address, and caddy only proxies HTTP, so the Minecraft
# protocol needs a plain TCP forwarder. *.tek.rip already wildcards to this
# host, so mc.tek.rip needs no DNS record of its own.
#
# Every connection reaches the game server from the VPS's tailnet address, so
# the server's own per-IP logging and banning see one client. The whitelist in
# server-modules/minecraft.nix is what actually gates who gets in.
{pkgs, ...}: let
  minipc = "100.85.180.11";
  port = 25565;
in {
  systemd.sockets.minecraft-proxy = {
    wantedBy = ["sockets.target"];
    socketConfig = {
      ListenStream = toString port;
      # Without this the proxy would only ever serve one player at a time.
      Accept = false;
    };
  };

  systemd.services.minecraft-proxy = {
    description = "TCP forwarder for mc.tek.rip";
    requires = ["minecraft-proxy.socket"];
    after = ["minecraft-proxy.socket" "tailscaled.service"];

    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${minipc}:${toString port}";
      DynamicUser = true;
      Restart = "on-failure";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      SystemCallArchitectures = "native";
    };
  };

  networking.firewall.allowedTCPPorts = [port];
}
