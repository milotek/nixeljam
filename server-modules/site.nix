# The apex domain: one page, a gif and a random single, both hotlinked from the
# public copyparty share at files.<domain>. Served here; the VPS's caddy fronts
# it at https://<domain>.
{
  config,
  pkgs,
  ...
}: let
  files = "https://files.${config.var.domain}";
in {
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
            <link rel="preload" as="image" href="${files}/Pictures/orange_cat_prentending_to_be_dead.webp" />
            <style>
              body {
                background: linear-gradient(#4b3e4b, #11111b);
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 1rem;
                margin: 0;
                min-height: 100vh;
              }
              img {
                width: 420px;
                height: 420px;
                transform-origin: bottom;
                cursor: pointer;
                filter: drop-shadow(0 0 40px #ffbdbd);
              }
              audio {
                max-width: 90vw;
              }
              #track {
                color: #cdd6f4;
                font: 0.9rem system-ui, sans-serif;
                text-align: center;
              }
              #flash {
                position: fixed;
                inset: 0;
                background: #fff;
                opacity: 0;
                pointer-events: none;
              }
            </style>
          </head>
          <body>
            <img id="gif" src="${files}/Pictures/Animated/wawawa.gif" alt="wawawa" />
            <div id="track"></div>
            <audio id="song" controls preload="metadata" crossorigin="anonymous"></audio>
            <div id="flash"></div>
            <audio id="shot" src="${files}/Music/Sounds/awm_fire.ogg" preload="auto"></audio>
            <script>
              const singles = "${files}/Music/Songs/Singles/";
              let ctx;

              const songs = fetch(singles + "?ls")
                .then((res) => res.json())
                .then((data) => data.files);

              const pick = () =>
                songs.then((list) => {
                  const name = list[Math.floor(Math.random() * list.length)].href;
                  song.src = singles + name;
                  track.textContent =
                    "milo@${config.var.domain} - " + decodeURIComponent(name);
                });

              pick();

              gif.addEventListener("click", () => {
                shot.currentTime = 0;
                shot.play();
                flash.animate([{opacity: 1}, {opacity: 0}], 600);
                gif.src = "${files}/Pictures/orange_cat_prentending_to_be_dead.webp";
                gif.alt = "dead";
                pick();
              });

              song.addEventListener("play", () => {
                ctx = new AudioContext();
                const analyser = ctx.createAnalyser();
                analyser.fftSize = 2048;
                analyser.smoothingTimeConstant = 0.4;
                ctx.createMediaElementSource(song).connect(analyser).connect(ctx.destination);

                const bins = new Uint8Array(analyser.frequencyBinCount);
                const squish = () => {
                  analyser.getByteFrequencyData(bins);
                  const bass = bins.slice(1, 7).reduce((a, b) => a + b) / 6 / 255;
                  const s = 1 + Math.max(0, bass - 0.5) * 0.5;
                  gif.style.transform = "scale(" + (2 - s) + ", " + s + ")";
                  requestAnimationFrame(squish);
                };
                squish();
              }, {once: true});
            </script>
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
