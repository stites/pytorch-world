{ pkgs ? import ./pin/nixpkgs.nix {} }:

let
  pytorch-releases = pkgs.callPackage ./pytorch/release.nix { };
  probtorch-releases = pkgs.callPackage ./probtorch/release.nix { };
  libtorch-releases = pkgs.callPackage ./libtorch/release.nix { };
in
{
  inherit (libtorch-releases) libtorch_cpu libtorch_cudatoolkit_10_0 libtorch_cudatoolkit_9_0;

  inherit (pytorch-releases) magma_240 pytorch36-vanilla pytorch36-mkl pytorch36-cu;

  inherit (probtorch-releases) probtorch36-cpu probtorch36-cu;
}
