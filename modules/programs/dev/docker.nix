{aspects, ...}: {
  flake.modules.nixos.docker = {
    config,
    pkgs,
    ...
  }: {
    imports = [aspects.common];

    virtualisation.docker.enable = true;
    users.users.${config.nixeljam.username}.extraGroups = ["docker"];
    environment.systemPackages = [pkgs.lazydocker];
  };
}
