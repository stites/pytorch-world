# { pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python36, pythonPackages ? pkgs.python36Packages }:
{ pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python3 }:

(pkgs.callPackage ./release.nix { inherit python; }).pytorch.env

