{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
  clips = "${home}/Videos/Recordings/Clips";
  clipSaved = pkgs.writeShellScript "clip-saved" ''
    ${pkgs.libnotify}/bin/notify-send -a Clips "Clip saved" "$(basename "$1")"
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

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
    home-manager.enable = true;
    njam = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };

    zellij.enable = true;

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
          user = config.var.username;
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

  systemd.user.services.replay = {
    Unit = {
      Description = "Instant replay buffer";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${clips}";
      ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w HDMI-A-1 -f 60 -c mp4 -a default_output -r 30 -replay-storage ram -sc ${clipSaved} -o ${clips}";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  xdg.configFile."niri/replay.kdl".text = ''
    binds {
        Mod+Print { spawn "systemctl" "--user" "kill" "-s" "SIGUSR1" "replay.service"; }
    }
  '';

  xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
    output "HDMI-A-1" {
        mode "2560x1440@143.999"
        position x=0 y=0
    }
    output "DP-1" {
        mode "2560x1440@143.972"
        position x=2560 y=0
    }
    include "./replay.kdl"
  '';
}
