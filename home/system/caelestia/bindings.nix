# The shell-owned half of the keymap. home/system/hyprland/bindings.nix drops
# its waybar-stack equivalents when var.desktopShell is "caelestia", so these
# are additions rather than overrides and no key ends up bound twice.
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, SPACE, global, caelestia:launcher"
      "$mod, X, global, caelestia:session"
      "$mod, N, exec, caelestia shell drawers toggle sidebar"
      "$mod, D, exec, caelestia shell drawers toggle dashboard"
      "$shiftMod, E, exec, caelestia emoji -p"
    ];

    bindl = [
      ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
      ", XF86MonBrightnessDown, global, caelestia:brightnessDown"

      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    # Holding $mod and then touching the mouse should dismiss the launcher
    # rather than leave it floating over whatever you were about to click.
    bindin = [
      "$mod, mouse:272, global, caelestia:launcherInterrupt"
      "$mod, mouse:273, global, caelestia:launcherInterrupt"
      "$mod, mouse_up, global, caelestia:launcherInterrupt"
      "$mod, mouse_down, global, caelestia:launcherInterrupt"
    ];
  };
}
