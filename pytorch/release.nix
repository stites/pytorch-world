{ pkgs ? import ../pin/nixpkgs.nix {}, python ? pkgs.python3 }:

with pkgs.lib.attrsets;
with builtins;

let
  protobuf = pkgs.protobuf;
  inherit (import ./generic.nix { inherit pkgs python; }) generic unstableGeneric;

in rec {
  pytorch-unstable = unstableGeneric ./unstable-pins/v1.4.0a0-2019-12-17.json "1.4.0a0" {
      mklSupport = false;
      cudaSupport = false;
      buildBinaries = false;
      openMPISupport = false;
  };

  pytorch = generic {
      mklSupport = false;
      cudaSupport = false;
      buildBinaries = false;
      openMPISupport = false;
  };

  pytorchWithOpenMPI = generic {
      mklSupport = false;
      cudaSupport = false;
      buildBinaries = false;
      openMPISupport = true;
  };

  pytorchWithMkl = generic {
    mklSupport = true;
    cudaSupport = false;
    buildBinaries = false;
    openMPISupport = false;
  };

  pytorchFull = generic {
      mklSupport = true;
      cudaSupport = false;
      buildBinaries = true;
      openMPISupport = true;
  };

  pytorchWithCuda = generic rec {
      mklSupport = false;
      cudaSupport = true;
      buildBinaries = true;
      openMPISupport = false;
      magma = pkgs.magma.override { inherit mklSupport; };
  };

  pytorchWithCuda10 = generic rec {
      mklSupport = false;
      cudaSupport = true;
      buildBinaries = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
      openMPISupport = false; openmpi = pkgs.openmpi.override { inherit cudaSupport cudatoolkit; };
      magma = pkgs.magma.override { inherit mklSupport cudatoolkit; };
  };

  pytorchWithCudaMkl = generic rec {
      mklSupport = true;
      cudaSupport = true;
      buildBinaries = true;
      openMPISupport = false; openmpi = pkgs.openmpi.override { inherit cudaSupport; };
      magma = pkgs.magma.override { inherit mklSupport; };
  };

  pytorchWithCuda10Mkl = generic rec {
      mklSupport = true;
      cudaSupport = true;
      buildBinaries = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
      openMPISupport = false; openmpi = pkgs.openmpi.override { inherit cudaSupport cudatoolkit; };
      magma = pkgs.magma.override { inherit mklSupport cudatoolkit; };
  };

  pytorchWithCuda10Full = generic rec {
      mklSupport = true;
      cudaSupport = true;
      buildBinaries = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
      openMPISupport = true; openmpi = pkgs.openmpi.override { inherit cudaSupport cudatoolkit; };
      magma = pkgs.magma.override { inherit mklSupport cudatoolkit; };
  };
  pytorchWithCudaFull = generic rec {
      mklSupport = true;
      cudaSupport = true;
      buildBinaries = true;
      openMPISupport = true; openmpi = pkgs.openmpi.override { inherit cudaSupport; };
      magma = pkgs.magma.override { inherit mklSupport ; };
  };
}

