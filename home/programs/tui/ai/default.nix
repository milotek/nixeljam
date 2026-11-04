{ config, pkgs, ... }:
let
  agents = ./AGENTS.md;
  voice = ./VOICE.md;
  opinions = ./OPINIONS.md;
  skills = import ./skills.nix { inherit pkgs; };
in
{
  xdg.configFile."opencode/AGENTS.md".source = agents;
  xdg.configFile."opencode/skills".source = skills;

  home.file.".claude/CLAUDE.md".source = agents;
  home.file.".claude/skills".source = skills;

  home.file."VOICE.md".source = voice;
  home.file."OPINIONS.md".source = opinions;

  home.sessionVariables.CLAUDE_CLI = "/etc/profiles/per-user/${config.var.username}/bin/claude";
}
