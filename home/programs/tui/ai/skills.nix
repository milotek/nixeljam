# Shared "skills" tree for every AI harness (Claude Code, opencode, hermes).
#
# Each skill is a directory holding a SKILL.md in the Anthropic skill format.
# Third-party skills are pinned from upstream; personal skills can be added as
# local paths. The result is a single read-only directory that every harness
# points at its own skills path:
#   Claude Code -> ~/.claude/skills
#   opencode    -> ~/.config/opencode/skills   (globs {skill,skills}/**/SKILL.md)
#   hermes      -> /opt/data/skills            (inside the VPS container)
{ pkgs }:
let
  inherit (pkgs) lib;

  # humanizer: strip AI-writing tells from prose.
  # https://github.com/blader/humanizer (MIT)
  humanizer = pkgs.fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    rev = "v2.9.1";
    hash = "sha256-qJIMwaas5Wnz270rUbPa4E5v2GQ62SQ1rKT0jmjYhyw=";
  };

  # "<skill name>" -> path to its SKILL.md. Add new skills here.
  skills = {
    humanizer = "${humanizer}/SKILL.md";
  };

  install = name: skillMd: ''
    mkdir -p "$out/${name}"
    cp ${lib.escapeShellArg skillMd} "$out/${name}/SKILL.md"
  '';
in
pkgs.runCommandLocal "agent-skills" { } ''
  mkdir -p "$out"
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList install skills)}
''
