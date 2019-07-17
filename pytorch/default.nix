{ stdenv, fetchurl, buildPythonPackage, pythonOlder,
  cudaSupport ? false, cudatoolkit ? null, cudnn ? null, nccl ? null,
  mklSupport ? false, mkl ? null,
  fetchFromGitHub, lib, numpy, pyyaml, cffi, typing, cmake, hypothesis, numactl,
  linkFarm, symlinkJoin, ninja, setuptools,
  utillinux, which, magma, bash }:

assert cudnn == null || cudatoolkit != null;
assert !cudaSupport || cudatoolkit != null;
assert !mklSupport || mkl != null;

let
  cudatoolkit_joined = symlinkJoin {
    name = "${cudatoolkit.name}-unsplit";
    paths = [ cudatoolkit.out cudatoolkit.lib ];
  };
  my_magma = magma.override {cudatoolkit = cudatoolkit;};

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
  USE_MKLDNN = 0; # mkl with cuda is broken
  USE_NCCL = 0; # multigpu looks broken broken
  # on deck
  USE_DISTRIBUTED = 0; # this might work

  # Suppress a weird warning in mkl-dnn, part of ideep in pytorch
  # (upstream seems to have fixed this in the wrong place?)
  # https://github.com/intel/mkl-dnn/commit/8134d346cdb7fe1695a2aa55771071d455fae0bc
  NIX_CFLAGS_COMPILE = lib.optionals (numpy.blasImplementation == "mkl") [ "-Wno-error=array-bounds" ];

  nativeBuildInputs = [
     cmake
     utillinux
     which
  ] ++ lib.optionals cudaSupport [ cudatoolkit_joined ]
    ++ lib.optionals mklSupport [ mkl ];

  buildInputs = [
     numpy.blas
  ] ++ lib.optionals cudaSupport [ cudnn my_magma  nccl ]
    ++ lib.optionals mklSupport [ mkl ]
    ++ lib.optionals stdenv.isLinux [ numactl ];

  propagatedBuildInputs = [
    cffi
    numpy
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
    platforms   = lib.platforms.linux;
    maintainers = with lib.maintainers; [ teh thoughtpolice ];
  };
}
