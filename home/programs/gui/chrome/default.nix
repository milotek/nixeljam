{ pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=UseOzonePlatform,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--enable-accelerated-video-decode"
      "--enable-gpu-rasterization"
      "--no-default-browser-check"
    ];
  };

  home.sessionVariables.BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";

  xdg.desktopEntries.google-chrome-private = {
    name = "Google Chrome (Incognito)";
    genericName = "Web Browser";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --incognito %U";
    icon = "google-chrome";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" ];
  };
}
