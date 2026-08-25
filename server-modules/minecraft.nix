# Paper Minecraft server, off by default. Start and stop it from the glance
# dashboard (see server-modules/minecraft-power.nix) rather than over SSH.
#
# The nix-minecraft module and its overlay are wired up in
# hosts/minipc/flake.nix - `inputs` only reaches this file through
# _module.args, which cannot be used from `imports`.
{pkgs, ...}: {
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true; # minipc has no public IP; this only opens the LAN/tailnet
    dataDir = "/var/lib/minecraft";

    servers.smp = {
      enable = true;
      autoStart = false;
      enableReload = true;
      restart = "no"; # a server you deliberately stopped should stay stopped

      package = pkgs.paperServers.paper-26_2;

      # Aikar's G1GC tuning. Xms == Xmx because a heap that grows on demand
      # makes G1 collect far more often than one sized up front.
      jvmOpts = builtins.concatStringsSep " " [
        "-Xms4G"
        "-Xmx4G"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
      ];

      serverProperties = {
        difficulty = 2;
        gamemode = "survival";
        allow-nether = true;
        enable-command-block = true;
        max-players = 10;
        motd = "nixeljam";
        simulation-distance = 8;
        spawn-protection = 0;
        view-distance = 12;
        white-list = true;
      };

      # Empty means nobody can join, including you. Add players as
      # <name> = "<uuid>"; UUIDs come from https://mcuuid.net.
      whitelist = {};

      # Paper patches the vanilla jar at startup and otherwise fetches it from
      # Mojang on first run. Pinning it keeps a cold start offline-clean.
      symlinks."cache/mojang_26.2.jar" = "${pkgs.vanillaServers.vanilla-26_2}/lib/minecraft/server.jar";
    };
  };
}
