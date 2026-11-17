# Git configuration
{
  aspects,
  lib,
  ...
}: {
  flake.modules.nixos.git.imports = [aspects.home-manager];
  flake.modules.nixos.git.options.nixeljam.git = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Name on your commits";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Email on your commits";
    };
  };
  flake.modules.nixos.git.config.home-manager.sharedModules = [
    (
      {osConfig, ...}: let
        name = osConfig.nixeljam.git.name;
        email = osConfig.nixeljam.git.email;
      in {
        programs = {
          gh.enable = true;
          git = {
            enable = true;
            ignores = [
              ".cache/"
              ".DS_Store"
              ".idea/"
              "*.swp"
              "*.elc"
              "auto-save-list"
              ".direnv/"
              "node_modules"
              "result"
              "result-*"
              ".superpowers/"
              ".claude/"
              "docs/superpowers/"
            ];
            settings = {
              user.name = name;
              user.email = email;
              init.defaultBranch = "main";
              pull.rebase = "true";
              push.autoSetupRemote = true;
              color.ui = "1";
              alias = {
                co = "checkout";
                fuck = "commit --amend -m";
                c = "commit -m";
                ca = "commit -am";
                forgor = "commit --amend --no-edit";
                graph = "log --all --decorate --graph --oneline";
                oops = "checkout --";
                l = "log";
                r = "rebase";
                s = "status --short";
                ss = "status";
                d = "diff";
                ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
                pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
                st = "status";
                br = "branch";
                hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
                llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
              };
            };
          };
        };

        home.persistence."/persist" = {
          directories = [".config/gh"];
        };
      }
    )
  ];
}
