{ config, ... }: let
  username = config.var.username;
in {
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; # PC — convenient for local network access
      AllowUsers = [ username ];
      MaxAuthTries = 5;
      LoginGraceTime = 30;
      X11Forwarding = false;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  # Same public key used across other hosts
  users.users."${username}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev"
  ];
}
