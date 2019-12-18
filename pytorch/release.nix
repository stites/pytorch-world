{ pkgs ? import ../pin/nixpkgs.nix {}, python ? pkgs.python3 }:

with pkgs.lib.attrsets;

let
  protobuf = pkgs.protobuf;
  generic = args: unstableGeneric null args;
  unstableGeneric = pinpath: args:
    let
      unstable = builtins.fromJSON (builtins.readFile pinpath);
      mypython = python.override {
        packageOverrides = self: super: rec {
          numpy = if (hasAttr "mklSupport" args && args.mklSupport)
                  then super.numpy.override { blas = pkgs.mkl; }
                  else super.numpy;
          stablept = (self.callPackage ./. ({ } // args));
          pytorch =
            if pinpath == null then stablept
            else stablept.overrideAttrs(old: {
              version = unstable.rev;
              doCheck = true; # always run tests on unstable packages
              src = pkgs.fetchFromGitHub {
                owner  = "pytorch";
                repo   = "pytorch";
                rev    = unstable.rev;
                fetchSubmodules = true;
                sha256 = unstable.sha256;
              };
            });
        };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ]);

in rec {
  pytorch-unstable = unstableGeneric ./unstable-pins/2019-12-12.json {
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

