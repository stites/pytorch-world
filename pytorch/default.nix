{ stdenv, fetchurl, buildPythonPackage, pythonOlder,
  cudaSupport ? false, cudatoolkit ? null, cudnn ? null, nccl ? null,
  mklSupport ? false, mkl ? null,
  openMPISupport ? false, openmpi ? null,
  fetchFromGitHub, lib, numpy, pyyaml, cffi, typing, cmake, hypothesis, numactl,
  linkFarm, symlinkJoin, ninja, setuptools,
  utillinux, which, magma, bash }:

assert cudnn == null || cudatoolkit != null;
assert !cudaSupport || cudatoolkit != null;
assert !mklSupport || mkl != null;
assert !openMPISupport || openmpi != null;

let
  cudatoolkit_joined = symlinkJoin {
    name = "${cudatoolkit.name}-unsplit";
    paths = [ cudatoolkit.out cudatoolkit.lib ];
  };
  my_magma = magma.override {cudatoolkit = cudatoolkit;};
  my_numpy = if mklSupport && numpy.blasImplementation != "mkl" then numpy.override { blas = mkl; } else numpy;
  my_openmpi = if openMPISupport && cudaSupport && !openmpi.cudaSupport then openmpi.override { cudaSupport = true; inherit cudatoolkit; } else openmpi;

  # Normally libcuda.so.1 is provided at runtime by nvidia-x11 via
  # LD_LIBRARY_PATH=/run/opengl-driver/lib.  We only use the stub
  # libcuda.so from cudatoolkit for running tests, so that we don’t have
  # to recompile pytorch on every update to nvidia-x11 or the kernel.
  cudaStub = linkFarm "cuda-stub" [{
    name = "libcuda.so.1";
    path = "${cudatoolkit}/lib/stubs/libcuda.so";
  }];
  cudaStubEnv = lib.optionalString cudaSupport
    "LD_LIBRARY_PATH=${cudaStub}\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ";

in buildPythonPackage rec {
  version = "1.1.0";
  pname = "pytorch";

  src = fetchFromGitHub {
    owner  = "pytorch";
    repo   = "pytorch";
    rev    = "v${version}";
    fetchSubmodules = true;
    sha256 = "1rckv7m3h04mgf7p61rmabszgxh5110ly6qq0qnp28vg7mckvgkh";
  };

  amsjit = fetchFromGitHub {
    owner  = "asmjit";
    repo   = "asmjit";
    rev    = "fc251c914e77cd079e58982cdab00a47539d7fc5";
    fetchSubmodules = true;
    sha256 = "14g99jnq8b3v2kz7s03zbifss760hxdf1dkn9d825jl0fcni5bx8";
  };

  preConfigure = lib.optionalString cudaSupport ''
    export CC=${cudatoolkit.cc}/bin/gcc CXX=${cudatoolkit.cc}/bin/g++
  '' + lib.optionalString (cudaSupport && cudnn != null) ''
    export CUDNN_INCLUDE_DIR=${cudnn}/include
  '';

  preFixup = ''
    function join_by { local IFS="$1"; shift; echo "$*"; }
    function strip2 {
      IFS=':'
      read -ra RP <<< $(patchelf --print-rpath $1)
      IFS=' '
      RP_NEW=$(join_by : ''${RP[@]:2})
      patchelf --set-rpath \$ORIGIN:''${RP_NEW} "$1"
    }
    for f in $(find ''${out} -name 'libcaffe2*.so')
    do
      strip2 $f
    done
  '';

  # Override the (weirdly) wrong version set by default. See
  # https://github.com/NixOS/nixpkgs/pull/52437#issuecomment-449718038
  # https://github.com/pytorch/pytorch/blob/v1.0.0/setup.py#L267
  PYTORCH_BUILD_VERSION = version;
  PYTORCH_BUILD_NUMBER = 0;
  USE_FBGEMM = 0; # this can't build because of CMAKE downloads

  # 7/24: Running Top:           MKL/CPU  +DISTRIBUTED  << works!
  # 7/24: Running Right-top:     MKL+CU   -DISTRIBUTED  << works!
  # 7/24: Running Right-bottom:  CU       +DISTRIBUTED  << works!
  # USE_DISTRIBUTED = 0; # Working with CPU/MKL? UNKNOWN. Working with CUDA? UNKNOWN.

  # USE_NCCL = 0; # LET'S FIX IT: multigpu looks broken broken
  # USE_SYSTEM_NCCL = 0; # if fix1 then 0 else 1; # Fix #1

  NCCL_ROOT_DIR    = lib.optionalString cudaSupport "${nccl.dev}";
  # NCCL_LIB_DIR     = lib.optionalString cudaSupport "${nccl.dev}/lib";
  # NCCL_INCLUDE_DIR = lib.optionalString cudaSupport "${nccl.dev}/include";

  # Suppress a weird warning in mkl-dnn, part of ideep in pytorch
  # (upstream seems to have fixed this in the wrong place?)
  # https://github.com/intel/mkl-dnn/commit/8134d346cdb7fe1695a2aa55771071d455fae0bc
  NIX_CFLAGS_COMPILE = lib.optionals (my_numpy.blasImplementation == "mkl") [ "-Wno-error=array-bounds" ];

  nativeBuildInputs = [
     cmake
     utillinux
     which
  ] ++ lib.optionals cudaSupport [ cudatoolkit_joined ]
    ++ lib.optionals openMPISupport [ my_openmpi ];

  buildInputs = [
     my_numpy.blas
  ] ++ lib.optionals cudaSupport [ cudnn my_magma ]
    ++ lib.optionals openMPISupport [ my_openmpi ]
    ++ lib.optionals stdenv.isLinux [ numactl ];

  propagatedBuildInputs = [
    cffi
    my_numpy
    pyyaml
    ninja
    setuptools
  ] ++ lib.optional (pythonOlder "3.5") typing;

  checkInputs = [ hypothesis ];
  checkPhase = ''
    ${cudaStubEnv}python test/run_test.py --exclude dataloader sparse torch utils thd_distributed distributed cpp_extensions
  '';

  meta = {
    description = "Open source, prototype-to-production deep learning platform";
    homepage    = https://pytorch.org/;
    license     = lib.licenses.bsd3;
    platforms   = with lib.platforms; [ linux darwin ];
    maintainers = with lib.maintainers; [ teh thoughtpolice ];
  };
}
