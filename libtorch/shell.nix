{ pkgs ? import ../pin/nixpkgs.nix {} }:

let
  build = pkgs.callPackage ./release.nix { };
in
pkgs.mkShell {
  buildInputs = [
    build.nightly.libtorch_cudatoolkit_10_0
    pkgs.clang_7
  ];
}
