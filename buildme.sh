#!/usr/bin/env bash
# terminate on the first failure
set -e

export BUILD=""

if ! command -v noti 2&> /dev/null; then
  echo "since the build-matrix is time consuming, use noti for status updates."
fi

trap 'noti -o -t "[EXIT-$?] from buildme.sh" -m "on build: $BUILD"' EXIT

function buildit {
  local PYTHON CODE
  if [[ "$2" == "py37" ]]; then
    PYTHON="pytorch37"
  else
    PYTHON="pytorch36"
  fi
  export BUILD="$PYTHON.$1"
  nix-build -A "$BUILD" artifacts.nix
  CODE=$?
  if [ "$CODE" != "0" ]; then
    exit $CODE
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
      noti -o -t "[1/4] pytorch on $2: Success"
      buildit "pytorchWithOpenMPI" "$2"
      noti -o -t "[2/4] pytorchWithOpenMPI on $2: Success"
      buildit "pytorchWithMkl"     "$2"
      noti -o -t "[3/4] pytorchWithMkl on $2: Success"
      buildit "pytorchFull"        "$2"
      noti -o -t "[4/4] pytorchFull on $2: Success"
      ;;&
  esac
  noti -o -t "buildCPU $1 on $2: Success"
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
               noti -o -t "[1/6] pytorchWithCuda on $2: Success"
               buildit "pytorchWithCudaMkl"    "$2"
               noti -o -t "[2/6] pytorchWithCudaMkl on $2: Success"
               buildit "pytorchWithCudaFull"   "$2"
               noti -o -t "[3/6] pytorchWithCudaFull on $2: Success"
               buildit "pytorchWithCuda10"     "$2"
               noti -o -t "[4/6] pytorchWithCuda10 on $2: Success"
               buildit "pytorchWithCuda10Mkl"  "$2"
               noti -o -t "[5/6] pytorchWithCuda10Mkl on $2: Success"
               buildit "pytorchWithCuda10Full" "$2"
               noti -o -t "[6/6] pytorchWithCuda10Full on $2: Success"
      ;;&
  esac
  noti -o -t "buildCUDA $1 on $2: Success"
}

function buildAll {
  DONOTCHECK="$(grep 'doCheck = false' pytorch/default.nix | wc -l)"
  if [ "$DONOTCHECK" == "1" ]; then
    for py in "py36" "py37"; do
      buildCPU  "all" "$py"
      buildCUDA "all" "$py"
    done
    # There is no environment variable to check for cachix. This will simply fail
    # if you are not authorized to push.
    export BUILD="cachix-push"
    nix-build artifacts.nix | cachix push pytorch-world
  else
    echo "buildAll was run with checkPhase on. This should not be done."
  fi
}

function buildfortests {
  DONOTCHECK="$(grep 'doCheck = true' pytorch/default.nix | wc -l)"
  if [ "$DONOTCHECK" == "1" ]; then
    buildCPU "mkl"    "py36"
    buildCUDA "mkl"   "py36"
    buildCPU "simple" "py36"
    buildCUDA "cu"    "py36"
  else
    echo "buildfortests is intended to be run run with checkPhase on."
  fi
}

buildAll
