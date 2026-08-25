# Bearer-authenticated HTTP endpoint that starts and stops the Minecraft
# server, so the glance dashboard can power it on without an SSH session.
#
# Bound to the tailnet only. The token ends up in the dashboard's page source
# (glance substitutes it into the button's fetch call), so anyone who can load
# the dashboard can drive this endpoint - keep both on the tailnet.
{
  config,
  pkgs,
  ...
}: let
  serverName = "smp";
  unit = "minecraft-server-${serverName}.service";

  listenAddress = "100.85.180.11"; # minipc's tailnet address
  port = 5000;

  api = pkgs.writers.writePython3Bin "minecraft-power" {flakeIgnore = ["E501"];} ''
    import hmac
    import json
    import os
    import subprocess
    from http.server import BaseHTTPRequestHandler, HTTPServer

    UNIT = "${unit}"

    with open(os.environ["API_KEY_PATH"]) as f:
        API_KEY = f.read().strip()

    ACTIONS = {"/mc/server/start": "start", "/mc/server/stop": "stop"}


    class Handler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def reply(self, code, body):
            payload = json.dumps(body).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            # The dashboard is served from a different origin to this API.
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
            self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
            self.end_headers()
            self.wfile.write(payload)

        def authorised(self):
            header = self.headers.get("Authorization", "")
            token = header[7:] if header.startswith("Bearer ") else ""
            # compare_digest rather than == so a wrong token cannot be guessed
            # one character at a time from response timing.
            return hmac.compare_digest(token, API_KEY)

        def do_OPTIONS(self):
            # 200 rather than the more usual 204: this handler always writes a
            # body, and a 204 carrying one desyncs HTTP/1.1 keep-alive.
            self.reply(200, {})

        def do_GET(self):
            if self.path != "/mc/server/status":
                return self.reply(404, {"error": "not found"})
            if not self.authorised():
                return self.reply(401, {"error": "unauthorized"})
            result = subprocess.run(["systemctl", "is-active", UNIT], capture_output=True, text=True)
            return self.reply(200, {"state": result.stdout.strip()})

        def do_POST(self):
            action = ACTIONS.get(self.path)
            if action is None:
                return self.reply(404, {"error": "not found"})
            if not self.authorised():
                return self.reply(401, {"error": "unauthorized"})
            try:
                subprocess.run(["systemctl", action, UNIT], check=True)
            except subprocess.CalledProcessError as e:
                return self.reply(500, {"error": str(e)})
            return self.reply(200, {"status": action})

        def log_message(self, fmt, *args):
            pass


    if __name__ == "__main__":
        HTTPServer((os.environ["LISTEN_ADDRESS"], int(os.environ["LISTEN_PORT"])), Handler).serve_forever()
  '';
in {
  sops.secrets.minecraft-api-key = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0400";
  };

  systemd.services.minecraft-power = {
    description = "Minecraft server power control API";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${api}/bin/minecraft-power";
      User = "minecraft";
      Group = "minecraft";
      Restart = "on-failure";
      Environment = [
        "API_KEY_PATH=${config.sops.secrets.minecraft-api-key.path}"
        "LISTEN_ADDRESS=${listenAddress}"
        "LISTEN_PORT=${toString port}"
      ];

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      SystemCallArchitectures = "native";
    };
  };

  # systemctl from a non-root user goes through polkit, so without this rule the
  # start/stop calls would silently fail an authorisation check. Scoped to the
  # one unit so a compromise of the API cannot touch anything else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.systemd1.manage-units" &&
        subject.user == "minecraft" &&
        action.lookup("unit") == "${unit}"
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [port];
}
