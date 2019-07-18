{ pkgs ? import <nixpkgs> {} }:

let
  probtorch-releases = pkgs.callPackage ./release.nix { };
in

probtorch-releases.probtorch36-cpu.env

