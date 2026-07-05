{ ... }:
let
  agents = ./AGENTS.md;
  voice = ./VOICE.md;
in
{
  # Shared agent instructions, fanned out to every installed AI tool.
  # AGENTS.md is the always-loaded ruleset; it points agents to ~/VOICE.md
  # (and ~/OPINIONS.md) to read on demand, so those live at the home root.

  # opencode: reads ~/.config/opencode/AGENTS.md as global rules
  xdg.configFile."opencode/AGENTS.md".source = agents;

  # Claude Code: reads ~/.claude/CLAUDE.md as global memory
  home.file.".claude/CLAUDE.md".source = agents;

  # Referenced by AGENTS.md via `read ~/VOICE.md`
  home.file."VOICE.md".source = voice;
}
