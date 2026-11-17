# Impermanence: "/" is wiped at boot (tmpfs), what must survive lives in /persist
# Hosts opt in by importing this aspect (and switching "/" to tmpfs in their disko config).
# Features declare their own state next to their config:
#   environment.persistence."/persist".directories = [...];   (system)
#   home.persistence."/persist".directories = [...];          (home-manager)
# Both do nothing on hosts without this aspect.
{aspects, ...}: {
  flake.modules.nixos.impermanence = {
    imports = [
      aspects.common
      aspects.home-manager
    ];

    # TODO: Impermanence perms 755 by default
    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;

      directories = [
        "/var/lib/nixos" # keeps uid/gid stable across boots
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/backlight" # remembers screen brightness
        "/var/lib/systemd/timers" # last-run timestamps (e.g. nix gc weekly)
        "/var/log"
        "/var/db/sudo/lectured" # remembers that the sudo lecture was already shown
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/var/lib/systemd/random-seed" # avoid a weak entropy pool on first boot
      ];
    };

    home-manager.sharedModules = [
      {
        home.persistence."/persist" = {
          directories = [
            ".config/nixos" # this repo itself (njam manages it here)
            ".local/share"
            ".local/state"
            ".cache"
            "Notes"
            "Music"
            "Projects"
            "Documents"
            "Downloads"
            "Pictures"
            "Videos"
          ];

          files = [
            ".ssh/known_hosts"
            ".config/sops/age/keys.txt"
          ];
        };
      }
    ];
  };
}
