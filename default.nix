{ pkgs ? import (builtins.fetchGit {
  name = "nixos-19.09";
  url = "https://github.com/nixos/nixpkgs";
  ref = "refs/heads/nixos-19.09";
  rev = "75f4ba05c63be3f147bcc2f7bd4ba1f029cedcb1";
}) { } }:

pkgs.stdenv.mkDerivation {
  pname = "purty";
  version = "2.0.0";
  src = ./.;

  buildInputs = [
    pkgs.haskell.packages.ghc822.ghc
    pkgs.cabal-install
    pkgs.stack

    pkgs.zlib
  ] ++ pkgs.haskellPackages.hfsevents.buildInputs;

  configurePhase = "";

  buildPhase = ''
    mkdir -p $out/stack-root
    export STACK_ROOT=$out/stack-root

    stack config set system-ghc --global true
    stack build
  '';

  installPhase = ''
    export STACK_ROOT=$out/stack-root

    mkdir -p $out/bin
    cp -r $(stack path --local-install-root)/bin/* $out/bin
  '';
}