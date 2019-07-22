{ pkgs ? import ../pin/nixpkgs.nix {}, pythonPackages ? pkgs.python36Packages }:

let
  generic = args: pkgs.callPackage ./. { inherit (pythonPackages) buildPythonPackage pytorch; };
in
{
  probtorch = generic { };
}

