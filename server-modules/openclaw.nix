# OpenClaw - self-hosted AI agent that reads files, runs commands and talks over
# chat channels. https://github.com/openclaw/openclaw
#
# Uses the first-party nix packaging (inputs.nix-openclaw), which ships a real
# NixOS module rather than a container: the gateway runs as a systemd service,
# config is rendered from Nix to /etc/openclaw/openclaw.json, and secrets arrive
# as sops files instead of living in the store.
#
# The module itself is imported in hosts/minipc/flake.nix - `inputs` reaches
# this file through _module.args, which cannot be used from `imports`.
#
# SECURITY: this agent gets a shell and filesystem access on this host. The
# gateway binds loopback only - reach it over SSH or Tailscale, never expose the
# port. Telegram access is limited to var.openclawTelegramUserId; anyone else
# who finds the bot gets nothing.
#
# Secrets (sops hosts/minipc/secrets/system-secrets.yaml):
#   openclaw-env             env file:  ANTHROPIC_API_KEY, OPENCLAW_GATEWAY_TOKEN
#   openclaw-telegram-token  the raw @BotFather token, nothing else
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  telegramUserId = config.var.openclawTelegramUserId or null;
in {
  # Upstream's flake advertises https://cache.garnix.io for prebuilt binaries,
  # but that host is NXDOMAIN as of 2026-08-19 (garnix.io itself still serves).
  # Pointing a substituter at a name that does not resolve just adds a failed
  # lookup to every build, so openclaw is built from source instead. If garnix
  # comes back, re-add it with key
  # cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=

  sops.secrets.openclaw-env.mode = "0400";
  sops.secrets.openclaw-telegram-token = {
    owner = "openclaw";
    mode = "0400";
  };

  services.openclaw-gateway = {
    enable = true;

    # Taken straight from the upstream flake rather than via an overlay against
    # our nixpkgs, so the build matches what upstream CI produces.
    package = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway;

    port = 18789;
    environmentFiles = [config.sops.secrets.openclaw-env.path];

    # Default is 2s, which hot-loops the unit whenever Telegram or the model
    # provider is unreachable.
    restartSec = 30;

    config = {
      gateway = {
        mode = "local";
        auth.token = {
          source = "env";
          provider = "default";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };
      };

      models.providers.anthropic.apiKey = {
        source = "env";
        provider = "default";
        id = "ANTHROPIC_API_KEY";
      };

      # Left off until the numeric user ID is known - a channel with an empty
      # allowFrom answers nobody, so there is no point starting it.
      channels = lib.optionalAttrs (telegramUserId != null) {
        telegram = {
          tokenFile = config.sops.secrets.openclaw-telegram-token.path;
          allowFrom = [telegramUserId];
        };
      };
    };
  };
}
