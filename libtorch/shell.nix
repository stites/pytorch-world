{ pkgs ? import ../pin/nixpkgs.nix {} }:

let
  build = pkgs.callPackage ./release.nix { };
in
pkgs.mkShell {
  buildInputs = [
    build.libtorch_cudatoolkit_10_2
    pkgs.clang_7
  ];
}
