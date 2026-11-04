{config, ...}: {
  programs.ydotool.enable = true;

  users.users."${config.var.username}".extraGroups = ["ydotool"];
}
