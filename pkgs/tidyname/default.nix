#- ## Tidyname
#-
#- Normalises filenames so paths stay portable and typeable. Structure keeps its
#- capitals, content does not:
#-
#- - **Base folders** (`Music/`, `Pictures/`) are never renamed.
#- - **Directories** keep their capitalisation at any depth, but lose spaces and
#-   punctuation: `Ball Race` becomes `Ball_Race`.
#- - **Convention docs** (`README.md`, `AGENTS.md`, `LICENSE`) are left alone.
#- - **Everything else** becomes lowercase `snake_case`: `MAP (Gloriana).png`
#-   becomes `map_gloriana.png`.
#-
#- Review happens before anything is touched: `plan` writes every rename to a
#- file you edit, `apply` executes what survived, `undo` reverses it.
#-
#- - `tidyname plan <dir>` - write a reviewable rename plan.
#- - `tidyname apply <plan>` - execute it, recording an undo log.
#- - `tidyname undo <log>` - put everything back.
#- - `tidyname check <dir>` - list non-conforming paths, exit 1 if any.
#- - `tidyname name <str>` - print the normalised form of a name.
{pkgs, ...}: {
  home.packages = [(import ./package.nix {inherit pkgs;})];
}
