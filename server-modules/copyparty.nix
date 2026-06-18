# copyparty — browser-accessible file server with upload support
# Access at http://<vps-ip>:3923
# To change the password: update the -a flag and rebuild
{pkgs, ...}: {
  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };
  users.groups.copyparty = {};

  systemd.services.copyparty = {
    description = "copyparty file server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.copyparty}/bin/copyparty \
          -p 3923 \
          -a milotek:changeme \
          -v /var/lib/copyparty:files:rwmd,milotek
      '';
      User = "copyparty";
      Group = "copyparty";
      StateDirectory = "copyparty";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  networking.firewall.allowedTCPPorts = [3923];
}
