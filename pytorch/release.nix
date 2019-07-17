{ pkgs ? import ./nix/nixpkgs.nix { } }:

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

  # pytorchMkl = python: generic {
  #   python;
  #   args = { mklSupport = true; };
  # };

  magma_240 = pkgs.callPackage ./nix/third_party/magma_250.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = false;
  };

  magma_240mkl = pkgs.callPackage ./nix/third_party/magma_250.nix {
    cudatoolkit = pkgs.cudatoolkit_10_0;
    mklSupport = true;
  };
in
{ inherit magma_240;

  pytorch36-vanilla = generic { python = pkgs.python36; };
  # pytorch37-vanilla = generic { python = pkgs.python37; };
  pytorch36-mkl = generic {
    python = pkgs.python36;
    args = { mklSupport = true; };
  };
  # pytorch37-mkl = generic {
  #   python = pkgs.python37;
  #   args = { mklSupport = true; };
  # };
  pytorch36-cu = generic {
    python = pkgs.python36;
    args = {
      mklSupport = false; magma = magma_240;
      cudaSupport = true;
      cudatoolkit = pkgs.cudatoolkit_10_0;
      cudnn = pkgs.cudnn_cudatoolkit_10_0;
      nccl = pkgs.nccl_cudatoolkit_10;
    };
  };
  # pytorch37-cu = generic {
  #   python = pkgs.python37;
  #   args = {
  #     mklSupport = false; magma = magma_240 false;
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
  #     magma = magma_240 true;
  #   };
  # };
  # pytorch37-mkl-cu = generic {
  #   python = pkgs.python37;
  #   args = {
  #     mklSupport = true;
  #     cudaSupport = true;
  #     cudatoolkit = pkgs.cudatoolkit_10_0;
  #     cudnn = pkgs.cudnn_cudatoolkit_10_0;
  #     magma = magma_240 true;
  #   };
  # };
}

