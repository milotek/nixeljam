{
  inputs,
  lib,
  ...
}: let
  agents = {
    claude-code = {
      package = "claude-code";
      directories = [".claude"];
      files = [".claude.json"];
    };
    codex = {
      package = "codex";
      directories = [".codex"];
    };
    opencode = {
      package = "opencode";
      directories = [".config/opencode"];
    };
    pi = {
      package = "pi";
      directories = [".pi"];
    };
    agy = {
      package = "antigravity-cli";
      directories = [".gemini"];
    };
  };
in {
  flake.modules.nixos =
    lib.mapAttrs (_: agent: {
      home-manager.sharedModules = [
        (
          {
            config,
            pkgs,
            ...
          }: {
            home.packages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.${agent.package}];

            home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
              inherit (agent) directories;
              files = agent.files or [];
            };
          }
        )
      ];
    })
    agents;
}
