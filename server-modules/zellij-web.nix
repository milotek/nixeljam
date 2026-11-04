# zellij won't bind beyond 127.0.0.1 without TLS, hence the socket proxy.
{
  config,
  pkgs,
  ...
}: let
  user = config.var.username;
  port = 8082;
  tailnetAddress = "100.85.180.11";

  # Not %U: in a system unit it expands to UID 0, not User=.
  start = pkgs.writeShellScript "zellij-web-start" ''
    export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"

    for _ in $(${pkgs.coreutils}/bin/seq 1 150); do
      [ -d "$XDG_RUNTIME_DIR" ] && break
      sleep 0.2
    done

    exec ${pkgs.zellij}/bin/zellij web --start --ip 127.0.0.1 --port ${toString port}
  '';
in {
  users.users.${user}.linger = true;

  systemd.services.zellij-web = {
    description = "zellij web server - browser client for ${config.var.hostname}'s sessions";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = user;
      ExecStart = start;
      Restart = "always";
      RestartSec = "5s";

      # The default OOMPolicy=stop kills every session when one pane process OOMs.
      OOMPolicy = "continue";
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
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString port}";
      PrivateTmp = true;
    };
  };
}
