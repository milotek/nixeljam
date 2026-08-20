{config, ...}: {
  # Ghostty.app itself is installed outside nix (it is already on this Mac), so we
  # only manage its config. We use an out-of-store symlink (per the internal guide)
  # so edits to the tracked config hot-reload without a full rebuild.
  #
  #   ~/.config/ghostty  ->  <repo>/hosts/work-mac/ghostty
  #
  # The directory (config + shaders + themes) was copied verbatim from this Mac.
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.var.configDirectory}/hosts/work-mac/ghostty";
}
