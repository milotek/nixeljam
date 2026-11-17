# VS Code: code editor
{aspects, ...}: {
  flake.modules.nixos.vscode = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.unstable.vscode];

        home.persistence."/persist".directories = [
          ".config/Code"
          ".vscode"
        ];
      })
    ];
  };
}
