{ version, sha256 }:
{ cmake, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "googletest";
  inherit version;
  src = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-${version}";
    inherit sha256;
  };
  buildInputs = [ cmake ];
}
