{aspects, ...}: {
  flake.modules.nixos.docker = {
    config,
    pkgs,
    ...
  }: {
    imports = [aspects.users];

    virtualisation.docker.enable = true;
    users.users."${config.nixeljam.username}".extraGroups = ["docker"];
    environment.systemPackages = [pkgs.lazydocker];
  };
}
