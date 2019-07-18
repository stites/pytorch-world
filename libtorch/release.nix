{ pkgs ? import ../pin/nixpkgs.nix {} }:

with pkgs;

let
  callCpu = opts: callPackage ./generic.nix ({ mklSupport = true; } // opts);
  callGpu = opts: callPackage ./generic.nix ({
    mklSupport = true;
    cudaSupport = true;
  } // opts);
in

{
  libtorch_cpu = callCpu {
    version = "1.1";
    sha256 = "09iwdy31zg9dzkrjx8mwpds9mxrv775msn01v1njkpjymvi7llz6";
  };
  libtorch_cudatoolkit_9_0 = callGpu {
    version = "1.1";
    # sha256 = "1y1kjqnqmac5cfl2cgdk2py5pwcxsyr6g2bk09spjs2d6g9cszld";
    sha256 = "0wl9xnv6bbpp0f93iwidvf7n1ns2nbd8ykyc9r163s3f04l295k3";
    cudatoolkit = cudatoolkit_9_0;
    cudnn = cudnn_cudatoolkit_9_0;
  };

  nightly = {
    libtorch_cpu = callCpu {
      version = "nightly";
      sha256 = "1dy85vqf13zk911y84aml0niz79p8v7x2lwy7jsbk1ixj36p2zsy";
    };
    libtorch_cudatoolkit_10_0 = callGpu {
      version = "nightly";
      sha256 = "1cvdrglgjn32dk904wz1l9lys06r8nn1xdhcx9rmyylpav89inic";
      cudatoolkit = cudatoolkit_10_0;
      cudnn = cudnn_cudatoolkit_10_0;
    };
    libtorch_cudatoolkit_9_0 = callGpu {
      version = "nightly";
      sha256 = "123r3xi2n6dbscvlcd6b2x7mglidkc3zybxg1lxwm5kk5n27r93p";
      cudatoolkit = cudatoolkit_9_0;
      cudnn = cudnn_cudatoolkit_9_0;
    };
  };
}
