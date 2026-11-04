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

    # Caddy on the VPS is the only thing that should reach this, over the
    # tailnet. Binding wider would publish an unauthenticated-until-signup UI.
    host = "127.0.0.1";
    port = 8093;

    environment = {
      # Setting this option replaces the module's defaults outright, so the
      # upstream telemetry opt-outs have to be repeated rather than merged.
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";

      OLLAMA_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";

      # On by default, and this host has no key and no route to it.
      ENABLE_OPENAI_API = "False";
    };
  };
}
