{aspects, ...}: {
  flake.modules.nixos.zellij = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      {
        programs.zellij.enable = true;

        programs.zsh.initContent = ''
          [[ -n $SSH_CONNECTION && -z $ZELLIJ ]] && zellij attach --create main
        '';
      }
    ];
  };
}
