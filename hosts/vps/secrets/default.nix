# sops-nix secrets for the VPS.
#
# The decryption identity is derived from the host's own SSH key
# (/etc/ssh/ssh_host_ed25519_key) — nothing needs to be copied onto the box.
# Secrets are encrypted to BOTH this host key and your primary age key, so you
# can still edit them from your pc: sops hosts/vps/secrets/secrets.yaml
{...}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
