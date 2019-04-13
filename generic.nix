{ stdenv, fetchzip, autoreconfHook, gettext
, cudaSupport ? false, cudatoolkit ? null, cudnn ? null
, mklSupport ? false , mkl ? null}:

let
  cudaVersion = builtins.splitVersion cudatoolkit.version;
  cudaMajor = builtins.elemAt cudaVersion 0;
  cudaMinor = builtins.elemAt cudaVersion 1;
  buildtype = if cudaSupport then "cu${cudaMajor}${cudaMinor}" else "cpu";

  cpu_sha256 = "1dccqb81031yrf7zx2myfi7yxi7i1nndgsl040gyh6ha4dxz98xs";
  cu9_sha256 = "123r3xi2n6dbscvlcd6b2x7mglidkc3zybxg1lxwm5kk5n27r93p";
  cu10_sha256 = "1cvdrglgjn32dk904wz1l9lys06r8nn1xdhcx9rmyylpav89inic";
  sha256 =
    if cudaSupport == false then cpu_sha256
    else if cudaMajor == "10" then cu10_sha256 else cu9_sha256;
in

assert cudaSupport == false || cudatoolkit != null;
assert cudaSupport == false || cudnn != null;
assert cudaSupport == false || ((cudaMajor == "10" && cudaMinor == "0") || (cudaMajor == "9" && cudaMinor == "0") );
assert mklSupport == false || mkl != null;

stdenv.mkDerivation rec {
  name = "libtorch-${version}";
  version = "nightly";

  src = fetchzip {
    url = "https://download.pytorch.org/libtorch/${version}/${buildtype}/libtorch-shared-with-deps-latest.zip";
    sha256 = "1cvdrglgjn32dk904wz1l9lys06r8nn1xdhcx9rmyylpav89inic";
  };

  propagatedBuildInputs = []
    ++ stdenv.lib.optionals cudaSupport [ cudatoolkit cudnn ]
    ++ stdenv.lib.optionals mklSupport [ mkl ];

  installPhase = ''
    ls $src
    mkdir $out
    cp -r {$src,$out}/bin/
    cp -r {$src,$out}/include/
    cp -r {$src,$out}/lib/
    cp -r {$src,$out}/share/
  '';

  meta = with stdenv.lib; {
    description = "libtorch";
    homepage = https://pytorch.org/;
    license = licenses.bsd3;
    # platforms = platforms.all;
  };
}
