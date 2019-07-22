{ pkgs ? import ../pin/nixpkgs.nix {} }:

let
  probtorch-releases = pkgs.callPackage ./release.nix { };
in

probtorch-releases.probtorch36-cpu.env

