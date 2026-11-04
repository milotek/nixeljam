{ pkgs }:
let
  inherit (pkgs) lib;

  humanizer = pkgs.fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    rev = "v2.9.1";
    hash = "sha256-qJIMwaas5Wnz270rUbPa4E5v2GQ62SQ1rKT0jmjYhyw=";
  };

  claudePlugins = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "e572d204d75338d76cbf9c06a53cf7b6e0c705d4";
    hash = "sha256-rPYAciCFf2D8jOCuangcoCgW1DlcfgZuoYXEGA8sTl4=";
  };

  mattpocock = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "0ab1b63a410a03d3627979a109c8695de27af954";
    hash = "sha256-Zg64vWsmtVk7WCH/f+bifju+L8yHeAwYbDNh6Ah43V0=";
  };

  skills = {
    humanizer = humanizer;
    skill-creator = "${claudePlugins}/plugins/skill-creator/skills/skill-creator";
  };

  # The prefix stops collisions with harness built-ins (mattpocock's code-review).
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

    # Harnesses key skills off the frontmatter name, so it must match the prefixed dir.
    sed -i "0,/^name:.*/s//name: $1/" "$out/$1/SKILL.md"
  }

  ${lib.concatStrings (lib.mapAttrsToList installSkill skills)}
  ${lib.concatStrings (map installCollection collections)}
''
