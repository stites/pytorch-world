let
  pkgs = import <nixpkgs> {};
  build = pkgs.callPackage ./build.nix { };
in
pkgs.mkShell {
  buildInputs = [
    build.nightly.libtorch_cudatoolkit_10_0
    pkgs.clang_7
  ];
}
