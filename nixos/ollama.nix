{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    loadModels = [
      "hf.co/huihui-ai/Mistral-Small-3.2-24B-Instruct-2506-abliterated-GGUF:Q4_K_M"
    ];
  };
}
