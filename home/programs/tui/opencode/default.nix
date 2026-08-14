{ pkgs, config, lib, ... }: {
  home.packages = [ pkgs.opencode ];

  programs.zsh.initContent = lib.mkAfter ''
    export ROUTER_API_KEY="$(cat ${config.sops.secrets.router-api-key.path} 2>/dev/null)"
    export OPENAI_API_KEY="$ROUTER_API_KEY"
  '';

  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    model = "router/claude-opus-4-8";
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
        models = {
          "qwen3.6:35b" = {
            name = "Qwen3.6 35B-A3B (MoE)";
          };
        };
      };
      router = {
        npm = "@ai-sdk/openai-compatible";
        name = "Router";
        options = {
          baseURL = "https://api.derouter.ai/openai/v1";
        };
        models = {
          "claude-opus-4-8"  = { name = "Claude Opus 4.8"; };
          "claude-opus-4-7"  = { name = "Claude Opus 4.7"; };
          "claude-opus-4-6"  = { name = "Claude Opus 4.6"; };
          "claude-sonnet-5"  = { name = "Claude Sonnet 5"; };
          "claude-sonnet-4-6" = { name = "Claude Sonnet 4.6"; };
          "claude-haiku-4-5" = { name = "Claude Haiku 4.5"; };
          "claude-fable-5"   = { name = "Claude Fable 5"; };
          "gpt-5.5"          = { name = "GPT-5.5"; };
          "gpt-5.4"          = { name = "GPT-5.4"; };
          "gpt-5.4-mini"     = { name = "GPT-5.4 Mini"; };
          "gpt-image-2"      = { name = "GPT Image 2"; };
        };
      };
    };
  };
}
