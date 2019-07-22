{ pkgs ? import ./pin/nixpkgs.nix {}, pythonPackages ? pkgs.python36Packages }:

let
  pytorch-releases = pkgs.callPackage ./pytorch/release.nix { inherit pkgs pythonPackages; };
  probtorch-releases = pkgs.callPackage ./probtorch/release.nix { inherit pkgs pythonPackages; };
  libtorch-releases = pkgs.callPackage ./libtorch/release.nix { };
in
{
  inherit (libtorch-releases) libtorch_cpu libtorch_cudatoolkit_10_0 libtorch_cudatoolkit_9_0;

  inherit (pytorch-releases) magma_240 pytorch pytorchWithMkl pytorchWithCuda10;

  inherit (probtorch-releases) probtorch;
}
