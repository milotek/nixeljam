# zellij-web — this host's terminal sessions, in a browser, at term.<host>.<domain>.
#
# The server shares the sessions the terminal already uses, so the page lands on
# the same "main" session an SSH login gets. That only holds if the unit resolves
# XDG_RUNTIME_DIR the way a login shell does — the sockets live under
# $XDG_RUNTIME_DIR/zellij, and a unit that misses them serves an empty session
# list rather than failing outright.
#
# WHY THE SOCKET PROXY. Zellij refuses to listen anywhere but 127.0.0.1 without
# a TLS certificate, and the VPS's caddy has to reach this across the tailnet.
# Rather than mint and rotate a self-signed cert on both ends, zellij stays on
# localhost and a socket proxy republishes it on the tailnet address — the same
# shape as every other service here: plain HTTP over wireguard, TLS at caddy.
#
# THIS IS A SHELL ON THE PUBLIC INTERNET. The only gate is a zellij login token,
# so anyone holding one has everything milotek has. Mint one by hand after a
# rebuild — they are displayed once and cannot be retrieved later:
#
#   sudo -u milotek env XDG_RUNTIME_DIR=/run/user/$(id -u milotek) \
#     zellij web --create-token --token-name phone
#
# Revoke with --revoke-token <name>, audit with --list-tokens.
{
  config,
  pkgs,
  ...
}: let
  user = config.var.username;
  port = 8082;
  tailnetAddress = "100.85.180.11"; # minipc's tailnet address

  # The UID is resolved at runtime rather than with %U, which in a *system* unit
  # expands to the service manager's UID (0) and not User=. That would point
  # zellij at /run/user/0, where none of the real sessions live.
  start = pkgs.writeShellScript "zellij-web-start" ''
    export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"

    # linger brings the user manager up at boot, but not necessarily before
    # this unit starts.
    for _ in $(${pkgs.coreutils}/bin/seq 1 150); do
      [ -d "$XDG_RUNTIME_DIR" ] && break
      sleep 0.2
    done

    exec ${pkgs.zellij}/bin/zellij web --start --ip 127.0.0.1 --port ${toString port}
  '';
in {
  users.users.${user}.linger = true;

  systemd.services.zellij-web = {
    description = "zellij web server — browser client for ${config.var.hostname}'s sessions";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = user;
      ExecStart = start;
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.sockets.zellij-web-tailnet = {
    description = "tailnet listener fronting the zellij web server";
    wantedBy = ["sockets.target"];
    socketConfig = {
      ListenStream = "${tailnetAddress}:${toString port}";
      # tailscale0 has no address yet when sockets.target is reached at boot.
      FreeBind = true;
    };
  };

  systemd.services.zellij-web-tailnet = {
    description = "forward tailnet connections to the zellij web server";
    requires = ["zellij-web.service" "zellij-web-tailnet.socket"];
    after = ["zellij-web.service" "zellij-web-tailnet.socket"];
    serviceConfig = {
      # No PrivateNetwork here, unlike the systemd manual's example: the backend
      # is a TCP port on the host, not a unix socket carried into the namespace.
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString port}";
      PrivateTmp = true;
    };
  };
}
