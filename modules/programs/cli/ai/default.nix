{
  flake.modules.nixos.ai.home-manager.sharedModules = [
    (
      {config, ...}: let
        agents = ./AGENTS.md;
        voice = ./VOICE.md;
        opinions = ./OPINIONS.md;
      in {
        # AGENTS.md is the always-loaded ruleset; it points agents to ~/VOICE.md
        # (and ~/OPINIONS.md) to read on demand, so those live at the home root.

        # opencode: reads ~/.config/opencode/AGENTS.md as global rules.
        xdg.configFile."opencode/AGENTS.md".source = agents;

        # Claude Code: reads ~/.claude/CLAUDE.md as global memory.
        home.file.".claude/CLAUDE.md".source = agents;

        # Referenced by AGENTS.md via `read ~/VOICE.md` and `read ~/OPINIONS.md`
        home.file."VOICE.md".source = voice;
        home.file."OPINIONS.md".source = opinions;

        home.sessionVariables.CLAUDE_CLI = "/etc/profiles/per-user/${config.var.username}/bin/claude";
      }
    )
  ];
}
