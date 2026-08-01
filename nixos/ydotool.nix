# ydotool: Wayland-compatible input automation (autoclicker / key + mouse injection).
# Runs the ydotoold daemon and grants the primary user access via the ydotool group.
{config, ...}: {
  programs.ydotool.enable = true;

  users.users."${config.var.username}".extraGroups = ["ydotool"];
}
