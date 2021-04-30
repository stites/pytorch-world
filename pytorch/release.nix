{ pkgs ? import ../pin/nixpkgs.nix {}, python ? pkgs.python39 }:

let
  generic = { args ? {} }:
    let
      mypython = python.override {
        packageOverrides = self: super: {
          numpy = super.numpy.override {
            blas = pkgs.blas.override {
              blasProvider = pkgs.mkl;
            };
          };
          pytorch = self.callPackage ./. ({} // args);
        };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ]);

  magma_250 = pkgs.callPackage ../deps/magma_250.nix {
    cudatoolkit = pkgs.cudatookit_10_2;
    mklSupport = false;
  };

  magma_250mkl = pkgs.callPackage ../deps/magma_250.nix {
    cudatoolkit = pkgs.cudatookit_10_2;
    mklSupport = true;
  };

  openmpi_cpu = pkgs.callPackage ../deps/openmpi.nix { cudaSupport = false; };
  openmpi_cuda = pkgs.callPackage ../deps/openmpi.nix {
    cudatoolkit = pkgs.cudatookit_10_2;
    cudaSupport = true;
  };
in rec {
  inherit magma_250 magma_250mkl;

  pytorch = generic { };

  pytorch-mkl = generic {
    args = { mklSupport = true; };
  };

  pytorch-openmpi = generic {
    args = { openMPISupport = true; openmpi = openmpi_cpu; };
  };

  pytorch-mkl-openmpi = generic {
    args = { mklSupport = true; openMPISupport = true; openmpi = openmpi_cpu; };
  };

  pytorchFull = generic {
    args = {
      mklSupport = true;
      openMPISupport = true;
      openmpi = openmpi_cpu;
      buildNamedTensor = true;
      buildBinaries = true;
    };
  };

  pytorch-cu = generic {
    args = {
      mklSupport = false; magma = magma_250;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatookit_10_2;
      cudnn = pkgs.cudnn_cudatookit_10_2;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };

  pytorch-cu-mkl = generic {
    args = {
      mklSupport = true; magma = magma_250mkl;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatookit_10_2;
      cudnn = pkgs.cudnn_cudatookit_10_2;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };

  pytorch-cu-mkl-openmpi = generic {
    args = {
      mklSupport = true; magma = magma_250mkl;
      openMPISupport = true; openmpi = openmpi_cuda; # openmpi will be altered to use the appropriate cudatoolkit
      cudaSupport = true;
      cudatoolkit = pkgs.cudatookit_10_2;
      cudnn = pkgs.cudnn_cudatookit_10_2;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };

  pytorchWithCuda10Full = generic {
    args = {
      mklSupport = true; magma = magma_250mkl;
      openMPISupport = true; openmpi = openmpi_cuda;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatookit_10_2;
      cudnn = pkgs.cudnn_cudatookit_10_2;
      nccl = pkgs.nccl_cudatoolkit_10;
      buildNamedTensor = true;
      buildBinaries = true;
    };
  };

  pytorchWithCudaFull = generic {
    args = {
      mklSupport = true;
      openMPISupport = true; openmpi = pkgs.callPackage ../deps/openmpi.nix { cudaSupport = true; };
      cudaSupport = true;
      magma = pkgs.callPackage ../deps/magma_250.nix { mklSupport = true; };
      buildNamedTensor = true;
      buildBinaries = true;
    };
  };
}

