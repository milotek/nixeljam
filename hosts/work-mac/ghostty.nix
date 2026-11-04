{config, ...}: {
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.var.configDirectory}/hosts/work-mac/ghostty";
}
