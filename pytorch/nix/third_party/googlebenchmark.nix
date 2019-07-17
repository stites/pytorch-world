{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "googlebenchmark-${version}";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "v${version}";
    sha256 = "1gld3zdxgc0c0466qvnsi70h2ksx8qprjrx008rypdhzp6660m48";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "google benchmark";
  };
}
