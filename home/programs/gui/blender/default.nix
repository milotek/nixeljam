# Stylix only ships Blender presets up to 4.5; drop this once it covers 5.0.
{
  config,
  lib,
  ...
}:
lib.mkIf config.stylix.targets.blender.enable {
  xdg.configFile."blender/5.0/scripts/presets/interface_theme/Stylix.xml".source =
    config.xdg.configFile."blender/4.5/scripts/presets/interface_theme/Stylix.xml".source;
}
