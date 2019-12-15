{ pkgs ? import ./pin/nixpkgs.nix {}
, python ? pkgs.python3, pythonPackages ? pkgs.python3Packages
}:

let
  pytorch-releases   = pkgs.callPackage ./pytorch/release.nix { inherit python; };
  probtorch-releases = pkgs.callPackage ./probtorch/release.nix { inherit python; };
in
{
  inherit (pytorch-releases)
    # cpu builds
    pytorch pytorchWithOpenMPI pytorchWithMkl pytorchFull

    # cuda builds
    pytorchWithCuda pytorchWithCuda10 pytorchWithCudaMkl pytorchWithCuda10Mkl
    pytorchWithCuda10Full pytorchWithCudaFull
    ;

  # inherit (probtorch-releases) probtorch probtorchWithCuda;

  libtorch = (pythonPackages.callPackage ./pytorch {}).dev;
  libtorch-cuda = (pythonPackages.callPackage ./pytorch { cudaSupport = true; }).dev;
  libtorch-cuda10 = (pythonPackages.callPackage ./pytorch (rec {
    cudaSupport = true;
    cudatoolkit = pkgs.cudatoolkit_10_0;
    cudnn = pkgs.cudnn_cudatoolkit_10_0;
    nccl = pkgs.nccl_cudatoolkit_10;
    magma = pkgs.magma.override { inherit cudatoolkit; };
  })).dev;
}
