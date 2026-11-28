{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
  noctalia = "${pkgs.noctalia-shell}/bin/noctalia-shell";
  inherit (inputs.self.lib) mime;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home = {
    packages = with pkgs; [
      blender
      godot
      unityhub
      prismlauncher
      lunar-client
      proton-vpn

      uv
      gdb
      clang
      clang-tools
      cmake
      gnumake

      caligula
      sttr
      slides
      pom
      tabiew
      lazyjournal
      mcat
      vhs
      figlet
      pastel
      chafa
      tty-solitaire
      bastet
      peaclock
      cbonsai
      pipes
      cmatrix
    ];

    # Don't touch this
    stateVersion = "24.05";
  };

  xdg.userDirs.setSessionVariables = true;

  xdg.mimeApps = mime.defaultFor "onlyoffice-desktopeditors.desktop" mime.types.office;

  sops = {
    age.keyFile = "${home}/.config/sops/age/keys.txt";
    defaultSopsFile = ./_secrets/secrets.yaml;
    secrets = {
      key.path = "${home}/.ssh/id_ed25519";
      key-pub.path = "${home}/.ssh/id_ed25519.pub";
      copyparty-password = {};
    };
  };

  programs = {
    zellij.enable = true;

    noctalia-shell.pluginSettings.screen-recorder.videoSource = "HDMI-A-1";

    git = {
      signing = {
        format = "ssh";
        key = "${home}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      settings.alias.essa = "push --force";
    };

    zsh.shellAliases = {
      v = "nvim";
      c = "clear";
      e = "exit";
      gcu = "git add . && git commit -m 'Update'";
      cl = "clang++ -std=c++26 -ggdb -pedantic-errors -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
    };

    rclone = {
      enable = true;
      remotes.copyparty = {
        config = {
          type = "webdav";
          url = "https://files.tek.rip";
          vendor = "other";
          user = config.home.username;
        };
        secrets.pass = config.sops.secrets.copyparty-password.path;
        mounts."/" = {
          enable = true;
          mountPoint = "${home}/files";
          options = {
            vfs-cache-mode = "writes";
            dir-cache-time = "30s";
          };
        };
      };
    };
  };

  # Start the replay buffer once noctalia has loaded the plugin
  systemd.user.services.replay = {
    Unit.After = ["noctalia-shell.service"];
    Service.ExecStart = pkgs.writeShellScript "replay" ''
      until [[ $(${noctalia} ipc show) == *"target plugin:screen-recorder"* ]]; do sleep 1; done
      ${noctalia} ipc call plugin:screen-recorder startReplay
    '';
    Install.WantedBy = ["noctalia-shell.service"];
  };

  xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
    output "HDMI-A-1" {
        mode "2560x1440@143.999"
        position x=0 y=0
    }
    output "DP-1" {
        mode "2560x1440@143.972"
        position x=2560 y=0
    }
  '';
}
