{
  description = "purty-nau";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-20.03";
    utils.url = "github:numtide/flake-utils";
    haskell-nix.url = "github:input-output-hk/haskell.nix";
  };

  outputs = { self, nixpkgs, haskell-nix, utils }:
    let 
      projectName = "purty";
      # Perhaps we should provide a more convinient way to do this?
      mkProject' = system: static: import nix/project.nix { 
        src = ./.;
        nixpkgs = haskell-nix.legacyPackages.${system};
        inherit static projectName;
      };
      mkProject = system: static: (mkProject' system static).${projectName};
      mkExes = system: (mkProject system false).components.exes;
      mkStatic = system: { "${projectName}-static" = (mkProject system true).components.exes.${projectName}; };
      mkTests = system: (mkProject system false).components.tests;
    in   
    utils.lib.eachDefaultSystem (system: rec {
      packages = (mkStatic system // mkExes system);
      defaultPackage = packages.${projectName};
      checks = mkTests system;
      devShell = (mkProject' system false).shellFor {
        tools = { "cabal-install" = "3.2.0.0"; }; 
      };
    });
}
