{ stdenv, fetchzip, autoreconfHook, gettext
, version, mkSrc
, cudaSupport ? false, cudatoolkit ? null, cudnn ? null
, mklSupport ? false , mkl ? null}:

let
  cudaVersion = builtins.splitVersion cudatoolkit.version;
  cudaMajor = builtins.elemAt cudaVersion 0;
  cudaMinor = builtins.elemAt cudaVersion 1;
  buildtype =
    let
      arch = if cudaSupport then "cu${cudaMajor}${cudaMinor}" else "cpu";
      nightly = if version == "nightly" then "${version}/" else "";
    in
      nightly + arch;
in

assert cudaSupport == false || (cudatoolkit != null && cudnn != null);
assert mklSupport == false || mkl != null;
assert version == "1.1" || version == "nightly";

stdenv.mkDerivation rec {
  name = "libtorch-${version}";
  inherit version;

  src = mkSrc buildtype;

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

  # postInstall = ''
  #   # Make boost header paths relative so that they are not runtime dependencies
  #   cd "$dev" && find include \( -name '*.hpp' -or -name '*.h' -or -name '*.ipp' \) \
  #     -exec sed '1i#line 1 "{}"' -i '{}' \;
  # '';

  meta = with stdenv.lib; {
    description = "libtorch";
    homepage = https://pytorch.org/;
    license = licenses.bsd3;
    platforms = with platforms; linux ++ stdenv.lib.optionals (!cudaSupport) darwin;
  };
}
