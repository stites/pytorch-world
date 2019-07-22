{ pkgs ? import ../pin/nixpkgs.nix {}, pythonPackages ? pkgs.python36Packages }:

let
  generic = args: pkgs.callPackage ./. ({
    inherit (pythonPackages) buildPythonPackage pythonOlder numpy pyyaml cffi typing hypothesis setuptools;
  } // args);

  magma_240 = pkgs.callPackage ../deps/magma_240.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = false;
  };

  magma_240mkl = pkgs.callPackage ../deps/magma_240.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = true;
  };
in
{ inherit magma_240;

  pytorch = generic { };
  pytorchWithMkl = generic { mklSupport = true; };
  pytorchWithCuda10 = generic {
    mklSupport = false; magma = magma_240;

    cudaSupport = true;
    cudatoolkit = pkgs.cudatoolkit_10_0;
    cudnn = pkgs.cudnn_cudatoolkit_10_0;
    nccl = pkgs.nccl_cudatoolkit_10;
  };
}

