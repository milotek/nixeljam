These are Milo Tekchandani's standing positions on tech, tools, and how software should be built.

Read this before making a call that has more than one defensible answer.
The point is that a decision made in one repo today matches the one made in another repo six months from now.

## How to use this file

- Find the section covering the decision at hand. If there is a position, follow it.
- If a position exists but this case genuinely argues against it, make that argument out loud. Do not quietly ignore it.
- If there is no position, ask, then write the answer back into this file under the right section.
- Do not record one-offs. A choice made for a single job, with no intent to repeat it, does not belong here.
- Prune what goes stale. A position about a tool no longer in use is worse than no position, because it still reads as current.

## Entry format

Every entry is a position and a reason, on one line.

- **The position, stated flat.** Why. What it buys, or what it avoids.

The reason carries the weight. A position with no reason can only be applied to cases it literally covers, and most cases are not literal matches.
State positions strongly. "Prefer X" invites relitigating every time; "X, unless Y" does not.

---

## Languages

_No entries yet._

## Frameworks and libraries

_No entries yet._

## Architecture and code structure

- **Delete the duplication before abstracting over it.** An abstraction that synchronises several copies of a fact is worth less than a change that leaves one copy, and it is easy to design the former without noticing the latter was available.
- **Abstractions describe what is wanted, not which backend provides it.** Naming the intent rather than the implementation means swapping the implementation later touches one module instead of every caller.

## Infrastructure and hosting

- **Own the public ingress on a box with a real public IP; do not put the front door behind Cloudflare Tunnel.** A tunnel is HTTP-only in practice, caps proxied request bodies at 100 MB on free and Pro, cannot carry a public game server without Spectrum, and terminates TLS on someone else's hardware. A cheap VPS keeps arbitrary TCP, unlimited body size and end-to-end control.
- **Tailscale is the only admin path; no host exposes a public SSH port.** An out-of-band door that does not depend on local DNS, the reverse proxy, or the ingress host means a broken rebuild cannot lock you out.
- **Machine-to-machine links between own hosts run over the tailnet, not hand-rolled SSH tunnels.** Tailscale already solves NAT traversal, reconnection and key rotation; an `ssh -R` loop with `Restart=always` only approximates them and needs a secret provisioned before it can even start.

## Data and storage

- **Structure carries capitals, content does not.** Base folders, nested folders and convention docs (`README.md`, `AGENTS.md`, `LICENSE`) keep the capitalisation they were given; everything else is lowercase. Capitalisation is what separates the scaffolding of a tree from the things stored in it, and lowercasing the scaffolding destroys that signal.
- **No spaces or punctuation in a path segment, at any level; words join with `_`.** Spaces force quoting in every shell, script and URL that touches the path, and punctuation shifts meaning between filesystems and clients.
- **Filenames are normalised on arrival, not swept up later.** A gate at the ingress point keeps a tree clean for free; a periodic cleanup pass only ever chases a backlog that regrows.

## Tooling and workflow

- **A bulk mutation is reviewed before it touches anything, never staged in the thing being changed.** A dry run that emits an editable plan lets the whole change be judged at once and abandoned for free; marking records in-place (a prefix, a flag column) mutates the very field under review, doubles the write, and leaves a half-migrated mess if the pass is never finished.
- **Anything that rewrites data in bulk ships with an undo log.** Recording old and new for each applied change costs one line and turns an irreversible operation into a reversible one.

## Testing

_No entries yet._

## AI and agents

- **Agent skills are pinned in the flake, never installed through a harness's plugin marketplace.** A `/plugin` install is mutable state inside one harness's dotfiles: unpinned, invisible to every other harness, and absent on the next machine, whereas a fetched revision is fanned to every harness on every host by the same rebuild.

---

## Ruled out

Things deliberately not used, and why. Saves re-proposing them.

_No entries yet._
