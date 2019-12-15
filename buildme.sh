#!/usr/bin/env bash
# terminate on the first failure
set -e

export BUILD=""

trap 'noti -o -t "[EXIT-$?] from buildme.sh" -m "on build: $BUILD"' EXIT

function buildit {
  local PYTHON_ PYTHON_PACKAGES_ CODE_
  export BUILD="$1"

  if [[ "$2" == "py37" ]]; then
    PYTHON_="pkgs.python37"
    PYTHON_PACKAGES_="pkgs.python37Packages"
  else
    PYTHON_="pkgs.python36"
    PYTHON_PACKAGES_="pkgs.python36Packages"
  fi
  nix-build -A "$BUILD" --arg python "$PYTHON_" --arg pythonPackages "$PYTHON_PACKAGES_" release.nix;
  CODE_=$?
  if [ "$CODE_" != "0" ]; then
    exit $CODE_
  fi
}

function buildCPU {
  case "$1" in
    "simple") buildit "pytorch"            "$2" ;;&
    "mkl")    buildit "pytorchWithMkl"     "$2" ;;&
    "full")   buildit "pytorchFull"        "$2" ;;&
    "mpi")    buildit "pytorchWithOpenMPI" "$2" ;;&
    "all")
      buildit "pytorch"            "$2"
      buildit "pytorchWithOpenMPI" "$2"
      buildit "pytorchWithMkl"     "$2"
      buildit "pytorchFull"        "$2"
      buildit "libtorch"           "$2"
      ;;&
  esac
  noti -o -t "buildCPU on $2: Success"
}

function buildCUDA {
  case "$1" in
    "cu")      buildit "pytorchWithCuda"       "$2" ;;&
    "cu10")    buildit "pytorchWithCuda10"     "$2" ;;&
    "mkl")     buildit "pytorchWithCudaMkl"    "$2" ;;&
    "mkl10")   buildit "pytorchWithCuda10Mkl"  "$2" ;;&
    "full")    buildit "pytorchWithCudaFull"   "$2" ;;&
    "full10")  buildit "pytorchWithCuda10Full" "$2" ;;&

    "only9")
               buildit "pytorchWithCuda"       "$2"
               buildit "pytorchWithCudaMkl"    "$2"
               buildit "pytorchWithCudaFull"   "$2"
      ;;&
    "only10")
               buildit "pytorchWithCuda10"     "$2"
               buildit "pytorchWithCuda10Mkl"  "$2"
               buildit "pytorchWithCuda10Full" "$2"
      ;;&
    "all")
               buildit "pytorchWithCuda"       "$2"
               buildit "pytorchWithCudaMkl"    "$2"
               buildit "pytorchWithCudaFull"   "$2"
               buildit "pytorchWithCuda10"     "$2"
               buildit "pytorchWithCuda10Mkl"  "$2"
               buildit "pytorchWithCuda10Full" "$2"
               buildit "libtorch-cuda"         "$2"
               buildit "libtorch-cuda10"       "$2"
      ;;&
  esac
  noti -o -t "buildCUDA on $2: Success"
}

function buildAll {
  buildCPU  "all" "py36"
  buildCUDA "all" "py36"
  buildCPU  "all" "py37"
  buildCUDA "all" "py37"
  nix-build artifacts.nix | cachix push pytorch-world
}

buildCPU "mkl"    "py36"
buildCUDA "mkl"   "py36"
buildCPU "simple" "py36"
buildCUDA "cu"    "py36"

