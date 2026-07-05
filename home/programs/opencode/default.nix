{ pkgs, ... }: {
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    model = "ollama/qwen3.6:35b";
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
    };
  };
}
