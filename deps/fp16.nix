{ cmake, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "FP16";
  version = "pytorch_11-dep";
  src = pkgs.fetchFromGitHub {
    owner = "Maratyszcza";
    repo = "FP16";
    rev = "febbb1c163726b5db24bed55cc9dc42529068997";
    # rev = "master";
    sha256 = "1ayrddk2zdkpzixvrlkvn4az2kx5jnivxhvffr8177yxjslrmbfw";
  };
}
