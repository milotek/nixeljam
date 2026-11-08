# Signal: messaging app
{
  flake.modules.nixos.signal.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.signal-desktop];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/Signal"
          ];
        };
      }
    )
  ];
}
