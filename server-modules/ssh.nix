{config, ...}: let
  username = config.var.username;
in {
  services.openssh = {
    enable = true;
    ports = [22];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      # Not redundant with the above: UsePAM defaults on, so leaving
      # keyboard-interactive enabled lets PAM prompt for a password anyway.
      KbdInteractiveAuthentication = false;
      AllowUsers = [username];
      MaxAuthTries = 3;
      LoginGraceTime = 20;
      X11Forwarding = false;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;

      # TCP and agent forwarding deliberately stay at their defaults (on):
      # -L reaches services Caddy doesn't front, and -A carries the Mac's agent
      # when hopping in from a host that has no milo key of its own.

      # PQ hybrids first. Pinning to bare curve25519 is a downgrade on
      # OpenSSH >= 10, which negotiates mlkem by default - the client warns
      # about store-now-decrypt-later if it is missing.
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
      ];
    };
  };

  users.users."${username}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev"
  ];
}
