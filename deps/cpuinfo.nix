{ cmake, stdenv, fetchFromGitHub, git, googletest, googlebenchmark }:

stdenv.mkDerivation rec {
  name = "cpuinfo";
  version = "pytorch_11-dep";
  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "cpuinfo";
    rev = "89fe1695edf9ee14c22f815f24bac45577a4f135";
    sha256 = "0c3fcmq96piqw2nlb9lrd0gk38izwj097l6xdf7s6dzmaackdwi3";
  };

  googletestSrc = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-1.8.0";
    sha256 = "0bjlljmbf8glnd9qjabx73w6pd7ibv43yiyngqvmvgxsabzr8399";
  };

  googlebenchmarkSrc = fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "v1.2.0";
    sha256 = "1gld3zdxgc0c0466qvnsi70h2ksx8qprjrx008rypdhzp6660m48";
  };

  cmakeFlags = [
    "-DGOOGLETEST_SOURCE_DIR=${googletestSrc}/src"
    "-DGOOGLEBENCHMARK_VERSION=0.0.0"
    ]; # "-DGOOGLEBENCHMARK_SOURCE_DIR=${googlebenchmarkSrc}/src" ];
  doCheck = false;
  buildInputs = [ git cmake googletest googlebenchmark ];
}
