{
  config,
  pkgs,
  ...
}: let
  panelPort = 8085;
  wingsPort = 8080;
  sftpPort = 2022;
  stateDir = "/var/lib/pelican";

  tailnetAddress = "100.85.180.11";
  appUrl = "http://${tailnetAddress}:${toString panelPort}";

  wings = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "pelican-wings";
    version = "1.0.0-beta29";
    src = pkgs.fetchurl {
      url = "https://github.com/pelican-dev/wings/releases/download/v${version}/wings_linux_amd64";
      hash = "sha256-ddgezyU2btPAWtbGzLrVMu2Ja4IZqp0sk6WvAD1pAAs=";
    };
    dontUnpack = true;
    installPhase = "install -Dm755 $src $out/bin/wings";
  };
in {
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  environment.systemPackages = [wings];

  # wings falls back to useradd (absent on NixOS) if this user is missing.
  users.users.pelican = {
    isSystemUser = true;
    group = "pelican";
    home = stateDir;
  };
  users.groups.pelican = {};

  users.users.${config.var.username}.extraGroups = ["docker"];

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0755 root root - -"
    "d ${stateDir}/panel 0755 root root - -"
    "d ${stateDir}/panel/data 0750 82 82 - -"
    "d ${stateDir}/panel/logs 0750 82 82 - -"
    "d ${stateDir}/panel/plugins 0750 82 82 - -"
    "Z ${stateDir}/panel/data 0750 82 82 - -"
    "Z ${stateDir}/panel/logs 0750 82 82 - -"
    "Z ${stateDir}/panel/plugins 0750 82 82 - -"
    "d /etc/pelican 0750 ${config.var.username} root - -"
    "d /var/log/pelican 0700 root root - -"
  ];

  virtualisation.oci-containers.containers.pelican-panel = {
    image = "ghcr.io/pelican/panel:latest";
    autoStart = true;
    ports = ["${toString panelPort}:80"];
    volumes = [
      "${stateDir}/panel/data:/pelican-data"
      "${stateDir}/panel/logs:/var/www/html/storage/logs"
      "${stateDir}/panel/plugins:/var/www/html/plugins"
    ];
    environment = {
      APP_URL = appUrl;
      APP_ENV = "production";
      APP_DEBUG = "false";
      XDG_DATA_HOME = "/pelican-data";
      BEHIND_PROXY = "false";
    };
    extraOptions = ["--add-host=host.docker.internal:host-gateway"];
  };

  systemd.services.pelican-wings = {
    description = "Pelican wings - game server daemon";
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "network-online.target"];
    wants = ["network-online.target"];
    startLimitIntervalSec = 180;
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/etc/pelican";
      ExecStart = "${wings}/bin/wings --config /etc/pelican/config.yml";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    unitConfig.ConditionPathExists = "/etc/pelican/config.yml";
  };

  systemd.paths.pelican-wings = {
    wantedBy = ["multi-user.target"];
    pathConfig = {
      PathExists = "/etc/pelican/config.yml";
      Unit = "pelican-wings.service";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    panelPort
    wingsPort
    sftpPort
  ];
}
