{ lib, cmake, stdenv, fetchFromGitHub
, blas, mklSupport ? false, mkl ? null
}:

assert !mklSupport || mkl != null;
let
  my_blas = if mklSupport then mkl else blas;
in

stdenv.mkDerivation rec {
  name = "fbgemm";
  version = "pytorch-1.1-dep";
  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "FBGEMM";
    rev = "6ec218e6ed5dcb9b5397a608a3b5b8027b236819";
    sha256 = "0pi2cskil909cch43wm55kvzmn42v6bvlxnci9r20724lq4byyn6";
  };
  buildInputs = [ cmake ];
  propagatedBuildInputs = [ my_blas ];
  enableParallelBuilding = true;

  asmjit = fetchFromGitHub {
    owner = "asmjit";
    repo = "asmjit";
    rev    = "fc251c914e77cd079e58982cdab00a47539d7fc5";
    sha256 = "14g99jnq8b3v2kz7s03zbifss760hxdf1dkn9d825jl0fcni5bx8";
  };

  cpuinfo = fetchFromGitHub {
    owner = "pytorch";
    repo = "cpuinfo";
    rev = "89fe1695edf9ee14c22f815f24bac45577a4f135";
    sha256 = "0c3fcmq96piqw2nlb9lrd0gk38izwj097l6xdf7s6dzmaackdwi3";
  };

  googletest = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-1.8.0";
    sha256 = "0bjlljmbf8glnd9qjabx73w6pd7ibv43yiyngqvmvgxsabzr8399";
  };
  cmakeFlags = [
    "-DGOOGLETEST_SOURCE_DIR=${googletest}"
    "-DASMJIT_SRC_DIR=${asmjit}"
    "-DCPUINFO_SOURCE_DIR=${cpuinfo}"
  ];
}
