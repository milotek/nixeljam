# Hermes Agent (Nous Research) - self-hosted autonomous AI agent.
# https://github.com/NousResearch/hermes-agent
#
# Runs alongside openclaw (server-modules/openclaw.nix), not instead of it.
# Upstream ships a real NixOS module now, so this is a hardened systemd unit
# with config rendered from Nix, rather than the Docker container the old
# feat/hermes-agent branch used.
#
# The module is imported in hosts/minipc/flake.nix - `inputs` reaches this file
# through _module.args, which cannot be used from `imports`.
#
# Native mode, not container mode: container mode would need a Docker or Podman
# socket, and handing an agent that socket on this host is equivalent to giving
# it root. State lives in /var/lib/hermes.
#
# SECURITY: this agent gets a shell and filesystem access on this host, same as
# openclaw. It shares the box with home-assistant, navidrome and slskd.
#
# Upstream is a self-declared Tier 2 platform - "commits to main may break
# packages" - so a bad upstream commit becomes a failed nixos-rebuild. Pin
# hermes-agent in flake.lock and update it deliberately, not as part of a
# blanket `nix flake update`.
#
# Secrets (sops hosts/minipc/secrets/system-secrets.yaml):
#   hermes-env   env file, one KEY=value per line. Do not set ANTHROPIC_API_KEY
#                when using Claude Code OAuth, because it can override OAuth.
{
  config,
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;

  hermesClaudeAuth = pkgs.stdenvNoCC.mkDerivation {
    pname = "hermes-claude-auth";
    version = "unstable";
    src = inputs.hermes-claude-auth;

    dontBuild = true;

    installPhase = ''
            site="$out/lib/python/site-packages"
            patches="$out/share/hermes-claude-auth/patches"

            mkdir -p "$site" "$patches"

            cp _hermes_claude_auth_bootstrap.py "$site/"
            cp anthropic_billing_bypass.py "$site/"
            cp anthropic_billing_bypass.py "$patches/"

      printf '%s\n' 'import _hermes_claude_auth_bootstrap' > "$site/sitecustomize.py"
    '';
  };

  hermesWithClaudeAuth = pkgs.symlinkJoin {
    name = "hermes-agent-with-claude-auth";
    paths = [inputs.hermes-agent.packages.${system}.default];
    nativeBuildInputs = [pkgs.makeWrapper];

    postBuild = ''
      wrapProgram "$out/bin/hermes" \
        --prefix PYTHONPATH : "${hermesClaudeAuth}/lib/python/site-packages" \
        --set HERMES_PATCHES_DIR "${hermesClaudeAuth}/share/hermes-claude-auth/patches"
    '';
  };
in {
  sops.secrets.hermes-env = {
    owner = "hermes";
    mode = "0400";
  };

  # Claude Code OAuth credentials must be available to the service user at
  # /var/lib/hermes/.claude/.credentials.json.
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes/.claude 0750 hermes hermes - -"
  ];

  services.hermes-agent = {
    enable = true;
    package = hermesWithClaudeAuth;

    settings = {
      model.default = "anthropic/claude-opus-5";
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };

    environmentFiles = [config.sops.secrets.hermes-env.path];

    # Puts the `hermes` CLI on PATH so the agent is reachable over SSH.
    addToSystemPackages = true;

    # Default is 5s, which hot-loops the unit whenever the model provider is
    # unreachable. Matches the openclaw unit.
    restartSec = 30;
  };

  # nixos/systemd-boot.nix sets DefaultTimeoutStopSec to 10s host-wide, which is
  # below the 30s of headroom the gateway wants for its shutdown drain, so every
  # restart SIGKILLs it mid-drain and lands in the journal as a phantom kill.
  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30;

  # addToSystemPackages exports HERMES_HOME host-wide, but it points at state
  # that is 2770 hermes:hermes, so the CLI is only usable by group members.
  # Without this the `hermes` on PATH dies reading .env before it can parse argv.
  users.users.${config.var.username}.extraGroups = ["hermes"];
}
