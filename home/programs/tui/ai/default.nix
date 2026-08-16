{ config, pkgs, ... }:
let
  agents = ./AGENTS.md;
  voice = ./VOICE.md;
  skills = import ./skills.nix { inherit pkgs; };
in
{
  # Shared agent instructions, fanned out to every installed AI tool.
  # AGENTS.md is the always-loaded ruleset; it points agents to ~/VOICE.md
  # (and ~/OPINIONS.md) to read on demand, so those live at the home root.
  # skills.nix builds one skills tree shared by every harness (and hermes).

  # opencode: reads ~/.config/opencode/AGENTS.md as global rules, and
  # discovers skills via {skill,skills}/**/SKILL.md under ~/.config/opencode.
  xdg.configFile."opencode/AGENTS.md".source = agents;
  xdg.configFile."opencode/skills".source = skills;

  # Claude Code: reads ~/.claude/CLAUDE.md as global memory and user skills
  # from ~/.claude/skills.
  home.file.".claude/CLAUDE.md".source = agents;
  home.file.".claude/skills".source = skills;

  # Referenced by AGENTS.md via `read ~/VOICE.md`
  home.file."VOICE.md".source = voice;

  home.sessionVariables.CLAUDE_CLI = "/etc/profiles/per-user/${config.var.username}/bin/claude";
}
