# ydotool: Wayland-compatible input automation (autoclicker / key + mouse injection).
{config, ...}: {
  programs.ydotool.enable = true;

  users.users."${config.var.username}".extraGroups = ["ydotool"];
}
