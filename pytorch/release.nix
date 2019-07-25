{ pkgs ? import ../pin/nixpkgs.nix { } }:

let
  # genericPytorch = pypkgs: pkgs.callPackage ./. {};

  mypackageOverrides = args: self: super: {
    pytorch = self.callPackage ./. ({} // args);
  };

  generic = { python, args ? {} }:
    let
      mypython = python.override {
        packageOverrides = mypackageOverrides args;
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ]);

  magma_250 = pkgs.callPackage ../deps/magma_250.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = false;
  };

  magma_250mkl = pkgs.callPackage ../deps/magma_250.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = true;
  };

  openmpi_cpu = pkgs.callPackage ../deps/openmpi.nix { cudaSupport = false; };
  openmpi_cuda = pkgs.callPackage ../deps/openmpi.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    cudaSupport = true;
  };
in
{ inherit magma_250 magma_250mkl;

  pytorch36-vanilla = generic { python = pkgs.python36; };
  pytorch36-mkl = generic {
    python = pkgs.python36;
    args = { mklSupport = true; };
  };
  pytorch36-cu = generic {
    python = pkgs.python36;
    args = {
      mklSupport = false; magma = magma_250;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };
  pytorch36-cu-mkl = generic {
    python = pkgs.python36;
    args = {
      mklSupport = true; magma = magma_250;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };

  # CHECK OPEN_MPI
  pytorch36-openmpi = generic {
    python = pkgs.python36;
    args = { openMPISupport = true; openmpi = openmpi_cpu; };
  };
  pytorch36-mkl-openmpi = generic {
    python = pkgs.python36;
    args = { mklSupport = true; openMPISupport = true; openmpi = openmpi_cpu; };
  };
  pytorch36-cu-mkl-openmpi-explicit = generic {
    python = pkgs.python36;
    args = {
      mklSupport = true; magma = magma_250;
      openMPISupport = true; openmpi = openmpi_cuda;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };
  pytorch36-cu-mkl-openmpi-implicit = generic {
    python = pkgs.python36;
    args = {
      mklSupport = true; magma = magma_250;
      openMPISupport = true; openmpi = openmpi_cpu;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };
  # pytorch37-vanilla = generic { python = pkgs.python37; };
  # pytorch37-mkl = generic {
  #   python = pkgs.python37;
  #   args = { mklSupport = true; };
  # };
  # pytorch37-cu = generic {
  #   python = pkgs.python37;
  #   args = {
  #     mklSupport = false; magma = magma_250 false;
  #     cudaSupport = true;
  #     cudatoolkit = pkgs.cudatoolkit_10_0;
  #     cudnn = pkgs.cudnn_cudatoolkit_10_0;
  #   };
  # };
  # pytorch36-mkl-cu = generic {
  #   python = pkgs.python36;
  #   args = {
  #     mklSupport = true;
  #     cudaSupport = true;
  #     cudatoolkit = pkgs.cudatoolkit_10_0;
  #     cudnn = pkgs.cudnn_cudatoolkit_10_0;
  #     magma = magma_250 true;
  #   };
  # };
  # pytorch37-mkl-cu = generic {
  #   python = pkgs.python37;
  #   args = {
  #     mklSupport = true;
  #     cudaSupport = true;
  #     cudatoolkit = pkgs.cudatoolkit_10_0;
  #     cudnn = pkgs.cudnn_cudatoolkit_10_0;
  #     magma = magma_250 true;
  #   };
  # };
}

