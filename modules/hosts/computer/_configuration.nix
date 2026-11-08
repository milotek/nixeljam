{config, ...}: {
  imports = [
    ./_hardware-configuration.nix
    ./_variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./_home.nix;

  # User password
  users.users.${config.var.username}.initialPassword = "changeme"; # CHANGEME: run `passwd` after the first login

  # Impermanence: declares what should survive a wipe of "/".
  # TODO: Impermanence perms 755 by default
  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections" # Wifi connections, VPN
      "/var/lib/bluetooth" # Bluetooth connections
      "/var/lib/nixos" # keeps uid/gid stable across boots
      "/var/lib/systemd/coredump"
      "/var/lib/upower" # battery calibration state
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

  # Don't touch this
  system.stateVersion = "26.05";
}
