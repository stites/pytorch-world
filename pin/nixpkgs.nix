{ ... }:
let
  hostpkgs = import <nixpkgs> {};

  srcDef = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  # srcDef = builtins.fromJSON (builtins.readFile ./tensorboard-2.0.json);

  nixpkgs = hostpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (srcDef) rev sha256;
  };

in import nixpkgs { }
