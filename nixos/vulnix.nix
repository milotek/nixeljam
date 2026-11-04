{pkgs, ...}: {
  environment.systemPackages = [pkgs.vulnix];

  systemd.services.vulnix-scan = {
    description = "Scan the system closure for known vulnerabilities (vulnix)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.vulnix}/bin/vulnix --system --cache-dir /var/cache/vulnix";
      CacheDirectory = "vulnix";
      # vulnix exits 1/2 when it finds vulnerabilities, not when the scan fails.
      SuccessExitStatus = "1 2";
    };
  };

  systemd.timers.vulnix-scan = {
    description = "Daily vulnix scan";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
