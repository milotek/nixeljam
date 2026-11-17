# Users configuration for NixOS
{aspects, ...}: {
  flake.modules.nixos.users = {
    config,
    pkgs,
    ...
  }: let
    username = config.nixeljam.username;
  in {
    imports = [aspects.common];

    programs.zsh.enable = true;
    # enable zsh autocompletion for system packages (systemd, etc)
    environment.pathsToLink = ["/share/zsh"];

    users = {
      defaultUserShell = pkgs.zsh;

      users.${username} = {
        isNormalUser = true;
        description = "${username} account";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
  };
}
