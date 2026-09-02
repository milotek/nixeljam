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

## Taste and defaults

- **Simple beats powerful, and complexity is only earned by a wall actually hit.** Caddy's three-line site block over nginx's forty: the exotic routing that justifies the verbose tool is usually hypothetical, and the day it stops being hypothetical is the day to reconsider, not before.
- **If it cannot be declared and rebuilt from the flake, it does not get installed.** Mutable undocumented state - configured by clicking, installed imperatively, existing on exactly one machine - is the single failure mode worth designing against, because it is invisible until the machine is gone.
- **Prefer tools that compose over tools that enclose.** Plain text, pipes and standard formats mean the next tool in the chain is a choice; a walled garden means the whole chain has to be replaced at once.
- **Aesthetics are a requirement, not a garnish.** Something looked at all day earns real attention to theming, typography and pixel-level polish, and that is a reason to pick one tool over an equivalent.
- **New and niche is fine; a single maintainer is the risk that matters.** Ghostty, Hyprland and Zellij are worth the churn because they are better and the crowd running them is competent, but a tool with no bus factor strands a config when it dies.
- **Absence from nixpkgs is a strike, not a veto.** It has to be worth packaging by hand, and sometimes it is.
- **Dependency sprawl is a smell, not a law.** It says the project does not care, which is weighted heavily, but no good tool is rejected over a count.
- **Rank the failures in this order: locked out, then data that cannot be recreated, then silent wrongness.** A box that is healthy but unreachable is the one that actually happens, and it is the one where every other safeguard is out of reach.
- **Get it right the first time.** Nothing here ships against a deadline, so a shortcut is not bought with anything; it is just deferred onto the person who maintains it, who is the same person.

## Languages

- **Python is the default for anything that runs as a service.** Broadest library coverage for the glue work these systems are made of, and the fastest path from idea to something running.
- **uv owns Python dependencies, inside a Nix devshell.** Nix supplies the interpreter and system libraries so the environment is reproducible; uv resolves and locks packages, because nixpkgs lags on Python libraries and fighting that is not worth it.
- **Bash is for work that is ours and finite.** A one-off, or something run a handful of times by nobody else, does not need a real language. Anything recurring, shared, or handed off has already outgrown it.

## Frameworks and libraries

- **A web UI is server-rendered HTML with minimal JavaScript until proven otherwise.** No build step, no framework churn, and nothing to migrate in two years.
- **Flask, not FastAPI or Django, for Python web.** It does what it is told and nothing else, which leaves the shape of the app to the app rather than to the framework's opinions.

## Architecture and code structure

- **Facts shared across modules are declared once, in `config.var`, and never repeated.** Username, domain, hostname and network interface are properties of the machine rather than of any module that happens to need them, so a module that hardcodes one is wrong even while it works.
- **Delete the duplication before abstracting over it.** An abstraction that synchronises several copies of a fact is worth less than a change that leaves one copy, and it is easy to design the former without noticing the latter was available.
- **Abstractions describe what is wanted, not which backend provides it.** Naming the intent rather than the implementation means swapping the implementation later touches one module instead of every caller.
- **Use the solution that already exists; write a bespoke one only when nothing available fits.** An icon provider, a library or an upstream default arrives tested, documented and already covering cases not yet thought of, where the hand-rolled equivalent (own icon SVGs, own helper) has to earn each of those one bug at a time. What is saved is not only the writing, it is every later fix and addition that someone else now makes on your behalf.

## Infrastructure and hosting

- **Own the public ingress on a box with a real public IP; do not put the front door behind Cloudflare Tunnel.** A tunnel is HTTP-only in practice, caps proxied request bodies at 100 MB on free and Pro, cannot carry a public game server without Spectrum, and terminates TLS on someone else's hardware. A cheap VPS keeps arbitrary TCP, unlimited body size and end-to-end control.
- **A service may be public; its admin interface is tailnet-only.** The thing users need and the thing that reconfigures it have different blast radii, and collapsing them means every authentication bug is a total compromise rather than a nuisance.
- **Tailscale is the only admin path; no host exposes a public SSH port.** An out-of-band door that does not depend on local DNS, the reverse proxy, or the ingress host means a broken rebuild cannot lock you out.
- **Machine-to-machine links between own hosts run over the tailnet, not hand-rolled SSH tunnels.** Tailscale already solves NAT traversal, reconnection and key rotation; an `ssh -R` loop with `Restart=always` only approximates them and needs a secret provisioned before it can even start.
- **Self-host by default; pay only where the constraint is physical or the catalogue is the product.** Spotify wins not on software but on storage: holding every album of every liked song costs more than the subscription. Nothing about that argument applies to a service whose data is already yours.
- **The flake declares the capability; the content lives in its own repo.** `programs.steam.enable` is portable and a Steam library is not, and the same line separates a Pelican module from which games run on it. Content gets a repo of its own that the flake clones and wires in, the way Obsidian pulls ObsidianVault, so it stays reproducible without being baked into a config other people could adopt.
- **Write modules as though a stranger will enable them, even though none will.** The discipline is not really about the stranger; forcing the split between capability and personal detail is what keeps the config from calcifying around one machine.
- **Anything that grants access is encrypted with sops; everything else stays plaintext.** Keys, tokens and passwords earn the ceremony. Hostnames, domains, ports and internal topology do not, and encrypting them buys no security while making the config unreadable.
- **Back up what cannot be recreated, and nothing else.** Photos, notes, the vault and tagged music have no other source. Service state is rebuildable from the flake, so paying to store it offsite is paying twice for the same thing.
- **A service runs native when nixpkgs ships a module for it or when it is the host's own plumbing; it gets a container when the alternative is hand-rolling the packaging.** The nspawn is an answer to "nobody has packaged this", not to "this might get compromised": a nixpkgs module arrives with hardening its maintainer wrote and keeps current, and an ingress, a power-management timer or a relay cannot be put in a private netns without destroying the thing they do. Isolation is a side benefit of the container, not the reason for it.
- **A hand-rolled systemd unit owes its own hardening block.** Writing `systemd.services` directly means taking on the job the nixpkgs maintainer would otherwise have done, and `User=` alone is not that job; either it goes in a container or it carries `ProtectSystem`, `NoNewPrivileges` and the rest explicitly.

## Data and storage

- **Postgres is the default database; SQLite only where the application already ships it.** Fluency in one database is worth more than the operational savings of a second one, and a daemon plus a dump schedule is a known, bounded cost. Where upstream has already chosen SQLite, leave it: fighting an application's own storage decision buys nothing.
- **Structure carries capitals, content does not.** Base folders, nested folders and convention docs (`README.md`, `AGENTS.md`, `LICENSE`) keep the capitalisation they were given; everything else is lowercase. Capitalisation is what separates the scaffolding of a tree from the things stored in it, and lowercasing the scaffolding destroys that signal.
- **No spaces or punctuation in a path segment, at any level; words join with `_`.** Spaces force quoting in every shell, script and URL that touches the path, and punctuation shifts meaning between filesystems and clients.
- **Filenames are normalised on arrival, not swept up later.** A gate at the ingress point keeps a tree clean for free; a periodic cleanup pass only ever chases a backlog that regrows.

## Tooling and workflow

- **Flake inputs are bumped all at once and often.** A single big-bang update after six months is unbisectable, whereas frequent small bumps keep each breakage attributable to the commit that caused it.
- **When a package in nixpkgs is outdated or broken, take it from unstable before writing anything.** An overlay, an `overrideAttrs` or a hand-written derivation is maintenance owned forever, and unstable has usually already fixed the problem for the price of one line.
- **A document exists only for what the code cannot say itself.** Migrations, decisions and procedures a human has to perform earn a file; prose describing what a module does does not, because the module is right there and the prose is the half that goes stale.
- **Small commits, one coherent change each.** The reason is not tidiness: a forty-line diff gets read and a nine-hundred-line one gets skimmed, so diff size is the real control on what actually gets reviewed.
- **Where a commit boundary goes is decided by revertibility, not by size.** If reverting exactly that commit leaves a working system, it is one commit; if it does not, the boundary is in the wrong place.
- **Commit messages carry the why; the diff carries the what.** A subject line naming the change is enough on its own, and a body exists only when there is a reason that the diff cannot show.
- **Big or risky work gets a branch and a PR; small verified changes go straight to main.** History stays linear and readable either way, and rebasing rather than merging is what keeps it that way.
- **Write a comment only to explain something that looks wrong but is not.** Nix and well-named code carry themselves; a comment earns its place when a reader would otherwise try to "fix" the line, and everything else is noise however true it is.
- **No process that needs a second person.** Design docs, review gates and sign-offs exist to coordinate people, and alone they are pure overhead. Small diffs and readable code survive without a company around them; the rest does not.
- **No monitoring stack.** Prometheus and Grafana for a house is more machinery than the thing it watches, and a dashboard that actually gets looked at beats alerts that get trained away. The exception is anything whose failure is silent and expensive, which earns an `OnFailure=` push and nothing more.
- **In someone else's repo, match their conventions exactly, even the ones that are wrong.** A file that is internally coherent costs a reviewer nothing; a file that is 90% theirs and 10% yours makes every reader stop and work out which rules apply where. Personal standards apply to personally owned code.
- **Pick the project first, but take the learning excuse when it is offered.** A project invented to justify a technology tends not to get finished, while a real project choosing between two viable stacks may as well pick the one that teaches something.
- **A bulk mutation is reviewed before it touches anything, never staged in the thing being changed.** A dry run that emits an editable plan lets the whole change be judged at once and abandoned for free; marking records in-place (a prefix, a flag column) mutates the very field under review, doubles the write, and leaves a half-migrated mess if the pass is never finished.
- **Anything that rewrites data in bulk ships with an undo log.** Recording old and new for each applied change costs one line and turns an irreversible operation into a reversible one.

## Testing

- **For personal infrastructure, running it is the test.** A rebuild that boots and serves the thing is stronger evidence than a unit test over glue code, which mostly ends up testing its own mocks.
- **Reviewing the diff, not writing a test, is the defence against code that works but is wrong.** The failure mode being guarded against is plausible-looking code that runs correctly, and a test written by whoever wrote the code inherits the same misunderstanding. Reading it does not.

## AI and agents

- **Every diff is read before it lands, with no exceptions.** That deliberately caps agent output at review capacity rather than generation capacity, which is the point: code nobody has read is not finished work, however well it runs.
- **An agent has to say why, and the reasoning is what gets judged.** Weak or absent justification makes the change suspect even when it works, because working is exactly what the bad case also does.
- **Reporting something as working means it was run.** An unverified claim of success is worse than an admitted uncertainty, because it spends the trust that makes the next report worth reading.
- **Agent skills are pinned in the flake, never installed through a harness's plugin marketplace.** A `/plugin` install is mutable state inside one harness's dotfiles: unpinned, invisible to every other harness, and absent on the next machine, whereas a fetched revision is fanned to every harness on every host by the same rebuild.

---

## Ruled out

Things deliberately not used, and why. Saves re-proposing them.

_No entries yet._
