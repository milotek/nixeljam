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
