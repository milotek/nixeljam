{pkgs}:
pkgs.runCommand "tidyname" {
  meta = {
    description = "Normalise filenames to lowercase snake_case, via a reviewable plan";
    mainProgram = "tidyname";
  };
} ''
  install -Dm755 ${./tidyname.py} $out/bin/tidyname
  substituteInPlace $out/bin/tidyname \
    --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3'
''
