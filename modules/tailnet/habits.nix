{inputs, ...}: {
  flake.modules.nixos.habits = {
    imports = [inputs.habits.nixosModules.default];

    services.habits.enable = true;
  };
}
