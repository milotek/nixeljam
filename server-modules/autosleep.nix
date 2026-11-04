{
  config,
  pkgs,
  ...
}: let
  cfg = config.var.autoSleep or {};
  sleepAt = cfg.sleepAt or "00:00";
  wakeAt = cfg.wakeAt or "08:00";
in {
  systemd.services.auto-sleep = {
    description = "Suspend until ${wakeAt}";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "auto-sleep" ''
        set -eu

        now=$(${pkgs.coreutils}/bin/date +%s)
        target=$(${pkgs.coreutils}/bin/date -d "today ${wakeAt}" +%s)
        if [ "$target" -le "$now" ]; then
          target=$(${pkgs.coreutils}/bin/date -d "tomorrow ${wakeAt}" +%s)
        fi

        ${pkgs.util-linux}/bin/rtcwake -m mem -u -s "$(( target - now ))"
      '';
    };
  };

  systemd.timers.auto-sleep = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "*-*-* ${sleepAt}:00";
  };
}
