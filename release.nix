{ pkgs ? import ./pin/nixpkgs.nix {} }:

let
  pytorch-releases = pkgs.callPackage ./pytorch/release.nix { };
  probtorch-releases = pkgs.callPackage ./probtorch/release.nix { };
  libtorch-releases = pkgs.callPackage ./libtorch/release.nix { };
in
{
  inherit (libtorch-releases) libtorch_cpu libtorch_cudatoolkit_10_0;

  inherit (pytorch-releases) magma_250 pytorch36 pytorch36-mkl-openmpi pytorch36-cu-mkl
  pytorch36-openmpi = generic {
pytorch36-mkl-openmpi
  pytorch36-cu-mkl-openmpi-implicit = generic {
  pytorch36-cu-mkl-openmpi-implicit-extras = generic {

  inherit (probtorch-releases) probtorch36-cpu probtorch36-cu;
}
