# Declarative login/sudo password for the primary user, sourced from sops so the
# password hash is never committed to the (public) repo in plaintext.
#
# Import this only on hosts that have NixOS-level sops configured, and add a
# `user-password` entry (a `mkpasswd -m yescrypt` hash) to that host's secrets.
{config, ...}: {
  # Make the declarative password authoritative. With the default
  # mutableUsers=true, hashedPasswordFile is applied only when the account is
  # first created; an already-existing (password-less) user keeps its locked
  # password and ignores it. false makes sops the source of truth every rebuild.
  users.mutableUsers = false;

  sops.secrets.user-password = {
    neededForUsers = true; # decrypt early, before users are created
  };

  users.users.${config.var.username}.hashedPasswordFile =
    config.sops.secrets.user-password.path;
}
