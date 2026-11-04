{
  config,
  lib,
  ...
}: {
  assertions = [
    {
      assertion = config.services.ollama.enable;
      message = "open-webui has no backend: import nixos/ollama.nix on this host too.";
    }
  ];

  services.open-webui = {
    enable = true;

    host = "127.0.0.1";
    port = 8093;

    environment = {
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";

      OLLAMA_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";

      ENABLE_OPENAI_API = "False";
    };
  };
}
