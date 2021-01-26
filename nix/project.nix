# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io> 
#
# SPDX-License-Identifier: MPL-2.0

{ nixpkgs
, static ? false
, projectName
, src
}:
let
  pkgs = if static then
    nixpkgs.pkgsCross.musl64
  else
    nixpkgs;
  project = pkgs.haskell-nix.stackProject {
    compiler-nix-name = "ghc884";
    src = pkgs.haskell-nix.haskellLib.cleanGit { inherit src; name="sources"; };
    modules = [{
      packages.purescript.patches = [ ./purescript-0.12.0.patch ];
      packages.${projectName} = {
       # package.ghcOptions = "-Werror";
      };
    }];
  };
in project
