{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.zellij-web = {
    config,
    pkgs,
    ...
  }: let
    port = 8082;
  in {
    imports = [
      aspects.tailnet
      aspects.zellij
    ];

    users.users.${config.nixeljam.username}.linger = true;

    home-manager.sharedModules = [
      ({
        config,
        lib,
        ...
      }: {
        programs.zellij.settings.web_sharing = "on";

        systemd.user.services.zellij-web = {
          Unit.Description = "zellij web client";
          Install.WantedBy = ["default.target"];
          Service = {
            ExecStart = "${lib.getExe config.programs.zellij.package} web --port ${toString port}";
            Restart = "always";
            # Sessions run in this unit's cgroup; one OOM-killed pane must not end them all
            OOMPolicy = "continue";
          };
        };
      })
    ];

    # zellij only serves non-local addresses over TLS, so the tailnet gets a plain proxy instead
    systemd.sockets.zellij-web-proxy = {
      wantedBy = ["sockets.target"];
      socketConfig = {
        ListenStream = "${tailnet.hosts.${config.networking.hostName}}:${toString port}";
        FreeBind = true;
      };
    };
    systemd.services.zellij-web-proxy.serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString port}";
  };
}
