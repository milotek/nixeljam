{
  aspects,
  config,
  inputs,
  ...
}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.copyparty = {
    config,
    lib,
    pkgs,
    ...
  }: let
    root = config.nixeljam.media;
    username = config.nixeljam.username;
    accounts = ["guest" "friend" "bros" username];

    copyparty =
      inputs.copyparty-midi.packages.${pkgs.stdenv.hostPlatform.system}.copyparty-unstable-full.override
      {extraPackages = [pkgs.fluidsynth];};

    # Hermes watches this tag to announce what friends drop into Downloads
    uploadLog = pkgs.writeShellScript "copyparty-upload-log" ''
      IFS=$'\t' read -r user vp sz < <(${lib.getExe pkgs.jq} -r '[.user, .vp, .sz] | @tsv' <<<"$1")
      [[ $user != ${username} && $vp == Downloads/* ]] || exit 0
      ${pkgs.util-linux}/bin/logger -t copyparty-upload "user=$user path=$vp size=$sz"
    '';

    settings = pkgs.writeText "copyparty.conf" ''
      [global]
        i: 0.0.0.0
        p: 3923
        rproxy: 1
        xff-src: ${tailnet.hosts.vps}/32
        daw
        e2dsa
        midi-sf: ${root}/Music/MIDI/soundfonts/gm.sf2
        xbu: j,c1,,${lib.getExe pkgs.tidyname},hook
        xau: j,${uploadLog}

      % ${config.sops.templates."copyparty-accounts.conf".path}

      [/]
        ${root}
        accs:
          g: *
          r: guest, friend
          rwmd: bros
          A: ${username}
        flags:
          unlist: ^lost.found/?$

      [/Downloads]
        ${root}/Downloads
        accs:
          g: *
          r: guest
          rwm: friend
          rwmd: bros
          A: ${username}

      [/Music/Songs/Singles]
        ${root}/Music/Songs/Singles
        accs:
          r: *
          rwmd: bros
          A: ${username}
    '';
  in {
    imports = [
      aspects.media
      aspects.secrets
      aspects.tidyname
    ];

    users.users.copyparty = {
      isSystemUser = true;
      group = "copyparty";
    };
    users.groups.copyparty = {};

    sops.secrets = lib.genAttrs (map (account: "copyparty/${account}") accounts) (_: {});

    sops.templates."copyparty-accounts.conf" = {
      owner = "copyparty";
      content = ''
        [accounts]
        ${lib.concatMapStrings (account: "  ${account}: ${config.sops.placeholder."copyparty/${account}"}\n") accounts}
      '';
    };

    systemd.tmpfiles.rules = [
      "d ${root} 0755 copyparty copyparty - -"
      "d ${root}/Downloads 0755 copyparty copyparty - -"
    ];

    systemd.services.copyparty = {
      description = "copyparty file server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      unitConfig.RequiresMountsFor = [root];
      environment.XDG_CONFIG_HOME = "/var/lib/copyparty-state";
      serviceConfig = {
        ExecStart = "${lib.getExe copyparty} -c ${settings}";
        User = "copyparty";
        StateDirectory = "copyparty-state";
        Restart = "on-failure";
      };
    };
  };
}
