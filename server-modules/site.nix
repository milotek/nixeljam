# The apex domain: one page, one gif hotlinked from the public copyparty share
# at files.<domain>. Served here; the VPS's caddy fronts it at https://<domain>.
{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;
    virtualHosts."site" = {
      root = pkgs.writeTextDir "index.html" ''
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>wawawa</title>
            <style>
              html,
              body {
                height: 100%;
                margin: 0;
              }
              body {
                background: #1e1e2e;
                display: grid;
                place-items: center;
              }
              img {
                max-width: 90vw;
                max-height: 90vh;
              }
            </style>
          </head>
          <body>
            <img
              src="https://files.${config.var.domain}/Pictures/Animated/wawawa.gif"
              alt="wawawa"
            />
          </body>
        </html>
      '';
      listen = [
        {
          addr = "0.0.0.0";
          port = 8090;
        }
      ];
    };
  };
}
