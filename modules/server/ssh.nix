{aspects, ...}: {
  flake.modules.nixos.ssh = {config, ...}: let
    username = config.nixeljam.username;
  in {
    imports = [aspects.users];

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [username];
      };
    };

    users.users.${username}.openssh.authorizedKeys.keys = [
      # CHANGEME: "ssh-ed25519 AAAA... you@host"
    ];
  };
}
