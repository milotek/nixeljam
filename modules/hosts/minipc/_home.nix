{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.self.lib) tailnet;
  ssh = "${config.home.homeDirectory}/.ssh";
in {
  home.packages = [inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default];

  home.file = {
    ".ssh/id_ed25519.pub".text = tailnet.key;
    ".ssh/allowed_signers".text = "* ${tailnet.key}";
  };

  programs.git = {
    signing = {
      format = "ssh";
      key = "${ssh}/id_ed25519.pub";
      signByDefault = true;
    };
    settings.gpg.ssh.allowedSignersFile = "${ssh}/allowed_signers";
  };

  # Noctalia always starts with keep-awake off
  systemd.user.services.noctalia-shell.Service.ExecStartPost = pkgs.writeShellScript "keep-awake" ''
    until ${config.programs.noctalia-shell.package}/bin/noctalia-shell ipc call idleInhibitor enable; do sleep 1; done
  '';

  xdg.userDirs.setSessionVariables = false;

  # Don't touch this
  home.stateVersion = "24.05";
}
