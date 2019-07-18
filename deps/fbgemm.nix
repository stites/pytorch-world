{ lib, cmake, stdenv, fetchFromGitHub
, openblas, mklSupport ? false, mkl ? null
, asmjit, cpuinfo, googletest
}:

stdenv.mkDerivation {
  name = "fbgemm";
  version = "pytorch-1.1-dep";
  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "FBGEMM";
    rev = "6ec218e6ed5dcb9b5397a608a3b5b8027b236819";
    sha256 = "0pi2cskil909cch43wm55kvzmn42v6bvlxnci9r20724lq4byyn6";
  };
  buildInputs = [ cmake googletest ];
  propagatedBuildInputs = [ openblas asmjit cpuinfo ]
    ++ lib.optional mklSupport [ mkl ];
}
