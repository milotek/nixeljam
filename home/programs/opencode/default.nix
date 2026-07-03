{ pkgs, ... }: {
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    model = "ollama/hf.co/huihui-ai/Mistral-Small-3.2-24B-Instruct-2506-abliterated-GGUF:Q4_K_M";
    provider = {
      ollama = {
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
      };
    };
  };
}
