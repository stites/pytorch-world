{ pkgs ? import ./pin/nixpkgs.nix {}
, python ? pkgs.python39
, pythonPackages ? pkgs.python39Packages
}:

let
  pytorch-releases   = pkgs.callPackage ./pytorch/release.nix { inherit python; };
in
{
  inherit (pytorch-releases)
    # cpu builds
    pytorch pytorch-mkl pytorch-openmpi pytorch-mkl-openmpi pytorchFull
    # cuda dependencies
    magma_250 magma_250mkl
    # cuda builds
    pytorch-cu pytorch-cu-mkl pytorch-cu-mkl-openmpi pytorchWithCuda10Full
    ;
  libtorch = (pythonPackages.callPackage ./pytorch {}).dev;
  libtorch-cuda = (pythonPackages.callPackage ./pytorch { cudaSupport = true; magma = pkgs.callPackage ./deps/magma_250.nix { }; }).dev;
}
