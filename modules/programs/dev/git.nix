# Git configuration (git, gh, lazygit)
{
  aspects,
  lib,
  ...
}: {
  flake.modules.nixos.git = {
    imports = [aspects.home-manager];

    options.nixeljam.git = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Git author name of the host's user";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Git author email of the host's user";
      };
    };

    config.home-manager.sharedModules = [
      (
        {
          config,
          lib,
          osConfig,
          ...
        }: let
          accent = "#${config.lib.stylix.colors.base0D}";
          muted = "#${config.lib.stylix.colors.base03}";
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
                user.name = osConfig.nixeljam.git.name;
                user.email = osConfig.nixeljam.git.email;
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

            # Lazygit is a simple terminal UI for git commands.
            lazygit = {
              enable = true;
              settings = lib.mkForce {
                disableStartupPopups = true;
                notARepository = "skip";
                promptToReturnFromSubprocess = false;
                update.method = "never";
                git = {
                  commit.signOff = true;
                  overrideGpg = true;
                  parseEmoji = true;
                };
                gui = {
                  theme = {
                    activeBorderColor = [
                      accent
                      "bold"
                    ];
                    inactiveBorderColor = [muted];
                  };
                  showListFooter = false;
                  showRandomTip = false;
                  showCommandLog = false;
                  showBottomLine = false;
                  nerdFontsVersion = "3";
                };
              };
            };
          };

          home.persistence."/persist".directories = [".config/gh"];
        }
      )
    ];
  };
}
