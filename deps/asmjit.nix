{ cmake, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "asmjit";
  version = "pytorch_11-dep";
  src = fetchFromGitHub {
    owner = "asmjit";
    repo = "asmjit";
    rev    = "fc251c914e77cd079e58982cdab00a47539d7fc5";
    # fetchSubmodules = true;
    sha256 = "14g99jnq8b3v2kz7s03zbifss760hxdf1dkn9d825jl0fcni5bx8";
  };
  buildInputs = [ cmake ];
}
