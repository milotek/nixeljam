# The apex domain: one page, one gif, inlined into the page because copyparty
# has no anonymous read to hotlink from. Served here; the VPS's caddy fronts it
# at https://<domain>.
{pkgs, ...}: {
  services.nginx = {
    enable = true;
    virtualHosts."site" = {
      root = pkgs.runCommand "site" {} "install -Dm444 ${./index.html} $out/index.html";
      listen = [
        {
          addr = "0.0.0.0";
          port = 8090;
        }
      ];
    };
  };
}
