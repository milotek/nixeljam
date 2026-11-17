# Signal: messaging app
{aspects, ...}: {
  flake.modules.nixos.signal.imports = [aspects.home-manager];
  flake.modules.nixos.signal.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.signal-desktop];

        home.persistence."/persist" = {
          directories = [
            ".config/Signal"
          ];
        };
      }
    )
  ];
}
