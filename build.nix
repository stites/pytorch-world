{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  libtorch_gpu = cudatoolkit: cudnn: callPackage ./generic.nix { mklSupport = true; cudaSupport = true; inherit cudatoolkit cudnn; };
in

{
  libtorch_cpu = callPackage ./generic.nix { mklSupport = true; };
  libtorch_cudatoolkit_10_0 = libtorch_gpu cudatoolkit_10_0 cudnn_cudatoolkit_10_0;
  libtorch_cudatoolkit_9_0 = libtorch_gpu cudatoolkit_9_0 cudnn_cudatoolkit_9_0;
}
