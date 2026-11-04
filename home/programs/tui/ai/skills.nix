# Shared "skills" tree for every AI harness (Claude Code, opencode).
#
# A skill is a directory holding a SKILL.md plus whatever that file references:
# scripts, assets, extra markdown. The whole directory is copied, because a
# skill trimmed down to its SKILL.md installs broken the moment upstream adds a
# reference file.
#
# Upstream skills are pinned here rather than installed through Claude Code's
# `/plugin` marketplace: a plugin lands as mutable state under ~/.claude, is
# invisible to every other harness, and does not exist on a fresh machine.
# Each harness points its own skills path at the result:
#   Claude Code -> ~/.claude/skills
#   opencode    -> ~/.config/opencode/skills   (globs {skill,skills}/**/SKILL.md)
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

  # Anthropic's plugin marketplace, vendored for the skills it carries.
  # https://github.com/anthropics/claude-plugins-official
  claudePlugins = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "e572d204d75338d76cbf9c06a53cf7b6e0c705d4";
    hash = "sha256-rPYAciCFf2D8jOCuangcoCgW1DlcfgZuoYXEGA8sTl4=";
  };

  # Matt Pocock's engineering skills, pinned at the revision his marketplace
  # entry publishes as v1.2.3.
  # https://github.com/mattpocock/skills (MIT)
  mattpocock = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "0ab1b63a410a03d3627979a109c8695de27af954";
    hash = "sha256-Zg64vWsmtVk7WCH/f+bifju+L8yHeAwYbDNh6Ah43V0=";
  };

  # "<skill name>" -> the directory holding its SKILL.md.
  skills = {
    humanizer = humanizer;
    skill-creator = "${claudePlugins}/plugins/skill-creator/skills/skill-creator";
  };

  # Directories where every child holding a SKILL.md is installed as a skill.
  # Names carry the collection prefix so an upstream cannot shadow a skill that
  # ships with the harness itself; mattpocock's `code-review` would otherwise
  # collide with Claude Code's.
  #
  # mattpocock also publishes `skills/in-progress` and `skills/misc`, which his
  # own plugin manifest leaves out. Scanning only these two directories tracks
  # what upstream considers released.
  collections = [
    {
      prefix = "mattpocock";
      dir = "${mattpocock}/skills/engineering";
    }
    {
      prefix = "mattpocock";
      dir = "${mattpocock}/skills/productivity";
    }
  ];

  installSkill = name: dir: ''
    install_skill ${lib.escapeShellArg name} ${lib.escapeShellArg dir}
  '';

  installCollection = { prefix, dir }: ''
    for skill in "${dir}"/*/; do
      [ -f "$skill/SKILL.md" ] || continue
      install_skill "${prefix}-$(basename "$skill")" "$skill"
    done
  '';
in
pkgs.runCommandLocal "agent-skills" { } ''
  mkdir -p "$out"

  install_skill() {
    if [ -e "$out/$1" ]; then
      echo "agent-skills: two sources both claim the skill name '$1'" >&2
      exit 1
    fi
    cp -r --no-preserve=mode,ownership "$2" "$out/$1"

    # Both harnesses key a skill off its frontmatter name, so a prefixed
    # directory whose SKILL.md still claims the bare name is either ignored or
    # collides with whatever else answers to that name.
    sed -i "0,/^name:.*/s//name: $1/" "$out/$1/SKILL.md"
  }

  ${lib.concatStrings (lib.mapAttrsToList installSkill skills)}
  ${lib.concatStrings (map installCollection collections)}
''
