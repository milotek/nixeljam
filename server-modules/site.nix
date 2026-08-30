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
                --glow: #ffbdbd;
              }
              body {
                /* The pink wash needs an opaque layer under it; on its own it
                   composites against the white canvas and blows out to near
                   white at the top. */
                background:
                  linear-gradient(
                    180deg,
                    rgba(255, 189, 189, 0.16) 0%,
                    rgba(255, 189, 189, 0.05) 26%,
                    rgba(255, 189, 189, 0) 52%
                  ),
                  linear-gradient(180deg, var(--base) 0%, var(--crust) 100%);
                background-attachment: fixed;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 1rem;
                margin: 0;
                min-height: 100vh;
              }
              /* Fixed so the bar stays out of the flex flow rather than
                 becoming a stray flex item. Its own box-shadow is the glow, so
                 the light travels with it instead of sitting in one place. */
              body::before {
                content: "";
                position: fixed;
                top: 0;
                left: 0;
                width: 40%;
                height: 2px;
                background: linear-gradient(
                  90deg,
                  transparent,
                  var(--glow),
                  transparent
                );
                box-shadow:
                  0 0 10px rgba(255, 189, 189, 0.95),
                  0 0 30px rgba(255, 189, 189, 0.45);
                animation: sweep 7s ease-in-out infinite alternate;
                pointer-events: none;
                z-index: 2;
              }
              /* Offsets are a share of the bar's own width, so -100% parks it
                 just off the left edge and 250% just off the right. */
              @keyframes sweep {
                from {
                  transform: translateX(-100%);
                }
                to {
                  transform: translateX(250%);
                }
              }
              @media (prefers-reduced-motion: reduce) {
                body::before {
                  animation: none;
                  transform: translateX(75%);
                }
              }
              img {
                position: relative;
                z-index: 3;
                width: 420px;
                height: 420px;
                transform-origin: bottom;
                cursor: pointer;
                filter: drop-shadow(0 0 40px rgba(255, 189, 189, 0.35));
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
              /* Above the bar, otherwise the shot flash is dimmed by its glow. */
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
