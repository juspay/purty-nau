{ inNixShell ? false }:
let attr = if inNixShell then "shellNix" else "defaultNix"; in
(import ./nix/shim.nix { src = ./.; }).${attr}
