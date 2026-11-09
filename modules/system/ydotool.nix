# ydotool: Wayland-compatible input automation (autoclicker / key + mouse injection).
{
  flake.modules.nixos.ydotool = {config, ...}: {
    programs.ydotool.enable = true;

    users.users."${config.var.username}".extraGroups = ["ydotool"];
  };
}
