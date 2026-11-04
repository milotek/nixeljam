{config, ...}: {
  users.mutableUsers = false;

  sops.secrets.user-password = {
    neededForUsers = true;
  };

  users.users.${config.var.username}.hashedPasswordFile =
    config.sops.secrets.user-password.path;
}
