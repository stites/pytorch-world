{ stdenv, fetchurl, fetchgit, buildPythonPackage, pythonOlder,
  cudaSupport ? false, cudatoolkit ? null, cudnn ? null, nccl ? null,
  mklSupport ? false, mkl ? null,
  openMPISupport ? false, openmpi ? null,
  buildNamedTensor ? false,
  buildBinaries ? false,
  fetchFromGitHub, lib, numpy, pyyaml, cffi, typing, cmake, hypothesis, numactl,
  linkFarm, symlinkJoin,

  # ninja (https://ninja-build.org) must be available to run C++ extensions tests,
  ninja,

  utillinux, which, magma, bash }:

assert cudnn == null || cudatoolkit != null;
assert !cudaSupport || cudatoolkit != null;
assert !mklSupport || mkl != null;
assert !openMPISupport || openmpi != null;
# assert cudaArchList == null || cudaArchList is list of strings

let
  cudatoolkit_joined = symlinkJoin {
    name = "${cudatoolkit.name}-unsplit";
    paths = [ cudatoolkit.out cudatoolkit.lib nccl.dev nccl.out ];
  };
  my_magma = magma.override {cudatoolkit = cudatoolkit; inherit mklSupport mkl; };
  my_numpy = if mklSupport && numpy.blasImplementation != "mkl" then numpy.override { blas = mkl; } else numpy;
  my_openmpi = if openMPISupport then openmpi.override { inherit cudaSupport cudatoolkit; } else openmpi;

  # Give an explicit list of supported architectures for the build, see
  # https://github.com/pytorch/pytorch/issues/23573
  # FIXME: Let users explicitly pass in cudaArchList
  cudaArchList = [
    # "3.0" < this architecture is causing problems
    "3.5"
    "5.0"
    "5.2"
    "6.0"
    "6.1"
    "7.0"
    "7.0+PTX"
    "7.5"
    "7.5+PTX"
  ];

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
  version = "1.2.0";
  pname = "pytorch";

  src = fetchFromGitHub {
    owner  = "pytorch";
    repo   = "pytorch";
    rev    = "v${version}";
    fetchSubmodules = true;
    sha256 = "1biyq2p48chakf2xw7hazzqmr5ps1nx475ql8vkmxjg5zaa071cz";
  };

  preConfigure = lib.optionalString cudaSupport ''
    export TORCH_CUDA_ARCH_LIST="${lib.strings.concatStringsSep ";" cudaArchList}"
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

  BUILD_NAMEDTENSOR = buildNamedTensor;
  # for pytorch
  USE_SYSTEM_NCCL=true;
  # NCCL_ROOT = lib.optionalString cudaSupport "${nccl.dev}";
  # NCCL_INCLUDE_DIR = lib.optionalString cudaSupport "${nccl.dev}/include";
  # NCCL_LIB_DIR = lib.optionalString cudaSupport "${nccl.dev}/lib";
  # # # GLoo doesn't seem to find NCCL
  # CFLAGS = lib.optionals cudaSupport ["-DNCCL_INCLUDE_DIR=${nccl.dev}/include" "-DNCCL_LIBRARY=${nccl.dev}/lib"]
  #    ++ lib.optionals mklSupport ["-Wno-error=array-bounds"];

  # Suppress a weird warning in mkl-dnn, part of ideep in pytorch
  # (upstream seems to have fixed this in the wrong place?)
  # https://github.com/intel/mkl-dnn/commit/8134d346cdb7fe1695a2aa55771071d455fae0bc
  # https://github.com/pytorch/pytorch/issues/22346
  #
  # Also of interest: pytorch ignores CXXFLAGS uses CFLAGS for both C and C++:
  # https://github.com/pytorch/pytorch/blob/v1.2.0/setup.py#L17
  NIX_CFLAGS_COMPILE = lib.optionals (my_numpy.blasImplementation == "mkl") [ "-Wno-error=array-bounds" ];

  # # cudaArchList includes Relevant issue: https://github.com/pytorch/pytorch/issues/23573
  # cmakeFlags = lib.optionals (lib.lists.length cudaArchList > 0) [ "-DTORCH_CUDA_ARCH_LIST=${lib.strings.concatStringsSep ";" cudaArchList}" ];


  nativeBuildInputs = [
    cmake
    utillinux
    which
    ninja
  ] ++ lib.optionals cudaSupport [ cudatoolkit_joined ];

  buildInputs = [
    my_numpy.blas
  ] ++ lib.optionals cudaSupport [ cudnn my_magma nccl ]
    ++ lib.optionals stdenv.isLinux [ numactl ];

  propagatedBuildInputs = [
    cffi
    my_numpy
    pyyaml
  ] ++ lib.optionals openMPISupport [ my_openmpi ]
    ++ lib.optional (pythonOlder "3.5") typing;

  checkInputs = [ hypothesis ninja ];
  checkPhase = "${cudaStubEnv}python test/run_test.py"
    # utils requires git, which is not allowed in the check phase
    + " --exclude utils"
    # --exclude dataloader sparse torch utils thd_distributed distributed cpp_extensions
    ;


  meta = {
    description = "Open source, prototype-to-production deep learning platform";
    homepage    = https://pytorch.org/;
    license     = lib.licenses.bsd3;
    platforms   = with lib.platforms; [ linux ] ++ lib.optionals (!cudaSupport) [ darwin ];
    maintainers = with lib.maintainers; [ teh thoughtpolice ];
  };
}
