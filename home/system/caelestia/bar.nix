{
  programs.caelestia.settings.bar = {
    clock.showIcon = false;
    persistent = true;
    popouts.activeWindow = false;

    status = {
      showAudio = true;
      showBattery = true;
      showBluetooth = true;
      showKbLayout = false;
      showLockStatus = false;
      showMicrophone = false;
      showNetwork = true;
    };

    workspaces = {
      activeIndicator = true;
      activeLabel = " ";
      activeTrail = false;
      label = " ";
      occupiedBg = false;
      occupiedLabel = " ";
      perMonitorWorkspaces = true;
      showWindows = false;
      shown = 9;
    };

    entries = [
      {
        id = "logo";
        enabled = true;
      }
      {
        id = "workspaces";
        enabled = true;
      }
      {
        id = "spacer";
        enabled = true;
      }
      {
        id = "activeWindow";
        enabled = true;
      }
      {
        id = "spacer";
        enabled = true;
      }
      {
        id = "tray";
        enabled = true;
      }
      {
        id = "statusIcons";
        enabled = true;
      }
      {
        id = "clock";
        enabled = true;
      }
      {
        id = "power";
        enabled = true;
      }
    ];
  };
}
