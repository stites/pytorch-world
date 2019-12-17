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
}
