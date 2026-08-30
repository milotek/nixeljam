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
              :root {
                --base: #1e1e2e;
                --crust: #11111b;
                --sapphire: #74c7ec;
                --mauve: #cba6f7;
                --pink: #f5c2e7;
              }
              body {
                background:
                  radial-gradient(120% 70% at 50% -10%, rgba(203, 166, 247, 0.3), transparent 62%),
                  radial-gradient(85% 50% at 50% 0%, rgba(137, 180, 250, 0.22), transparent 68%),
                  linear-gradient(180deg, #262639 0%, var(--base) 45%, var(--crust) 100%);
                background-attachment: fixed;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 1rem;
                margin: 0;
                min-height: 100vh;
              }
              /* Fixed so these stay out of the flex flow rather than becoming
                 stray flex items. Two layers read as neon: a hairline filament,
                 and a blurred bloom for the light it throws onto the page. */
              body::before,
              body::after {
                content: "";
                position: fixed;
                inset: 0 0 auto 0;
                pointer-events: none;
              }
              body::before {
                height: 2px;
                background: linear-gradient(
                  90deg,
                  transparent 0%,
                  var(--sapphire) 20%,
                  var(--mauve) 40%,
                  var(--pink) 50%,
                  var(--mauve) 60%,
                  var(--sapphire) 80%,
                  transparent 100%
                );
                background-size: 200% 100%;
                animation: drift 14s linear infinite;
                box-shadow:
                  0 0 8px rgba(203, 166, 247, 0.9),
                  0 0 26px rgba(137, 180, 250, 0.55);
                z-index: 2;
              }
              body::after {
                height: 200px;
                background: radial-gradient(
                  60% 100% at 50% 0%,
                  rgba(203, 166, 247, 0.35),
                  rgba(137, 180, 250, 0.12) 45%,
                  transparent 75%
                );
                filter: blur(22px);
                z-index: 1;
              }
              @keyframes drift {
                to {
                  background-position: 200% 0;
                }
              }
              @media (prefers-reduced-motion: reduce) {
                body::before {
                  animation: none;
                }
              }
              img {
                position: relative;
                z-index: 3;
                width: 420px;
                height: 420px;
                transform-origin: bottom;
                cursor: pointer;
                filter: drop-shadow(0 0 40px rgba(137, 180, 250, 0.25));
              }
              audio {
                position: relative;
                z-index: 3;
                max-width: 90vw;
              }
              #track {
                position: relative;
                z-index: 3;
                color: #cdd6f4;
                font: 0.9rem system-ui, sans-serif;
                text-align: center;
              }
              /* Above the glow layers, otherwise the shot flash is dimmed by them. */
              #flash {
                position: fixed;
                inset: 0;
                background: #fff;
                opacity: 0;
                pointer-events: none;
                z-index: 10;
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
