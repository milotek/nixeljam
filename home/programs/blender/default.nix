# Stylix's blender target only installs its theme preset for Blender versions
# 3.0-4.5 (hardcoded list in the upstream module). We run 5.2, so mirror the
# already-generated Stylix.xml into the 5.2 preset dir. The theme XML format is
# compatible across these versions. Remove once upstream stylix ships 5.x.
#
# NOTE: Blender stores the *active* theme in userpref.blend, so this only makes
# the preset selectable — pick it once via Edit ▸ Preferences ▸ Themes ▸ Presets.
{
  config,
  lib,
  ...
}:
lib.mkIf config.stylix.targets.blender.enable {
  xdg.configFile."blender/5.2/scripts/presets/interface_theme/Stylix.xml".source =
    config.xdg.configFile."blender/4.5/scripts/presets/interface_theme/Stylix.xml".source;
}
