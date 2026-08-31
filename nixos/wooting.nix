# Grants userspace access to Wooting keyboards so Wootility (wootility.io via
# WebHID in a Chromium browser) can edit the board's onboard keymap.
{pkgs, ...}: {
  services.udev.packages = [pkgs.wooting-udev-rules];
}
