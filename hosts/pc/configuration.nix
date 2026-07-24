{config, lib, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/nvidia.nix # Remove this line if you don't have an Nvidia GPU
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/hyprland.nix
    ../../nixos/usbguard.nix
../../nixos/gaming.nix
    ../../nixos/ssh.nix
    ../../nixos/docker.nix
    ../../nixos/ollama.nix

    ../../nixos/reverse-tunnel.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Reachable via the VPS at:
  #   ssh -p 2222 milotek@tek.rip     (public port)
  #   https://remote.pc.tek.rip       (noVNC desktop, fronted by the VPS's caddy)
  custom.reverseTunnel = {
    enable = true;
    sopsFile = ./secrets/system-secrets.yaml;
    forwards = [
      # sshd: public port on the VPS.
      {
        remoteBind = "*";
        remotePort = 2222;
        localPort = 22;
      }
      # noVNC web client: private port on the VPS, fronted by caddy over TLS.
      {
        remoteBind = "localhost";
        remotePort = 6080;
        localPort = 6080;
      }
    ];
  };

  # USBGuard: currently set to allow all devices.
  # Once stable, run `sudo usbguard generate-policy` with all devices plugged in,
  # paste the output into rules below, then switch implicitPolicyTarget back to "block".
  services.usbguard.implicitPolicyTarget = lib.mkForce "allow";

  # Cleared — rules were from the laptop and don't match this machine's devices.
  # Regenerate with: sudo usbguard generate-policy
  services.usbguard.rules = "";

  # utils.nix sets console.keyMap = keyboardLayout ("gb"), but loadkeys needs "uk"
  console.keyMap = lib.mkForce "uk";

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech G502 X Plus]
    MatchName=Logitech G502 X PLUS
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES
  '';

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
