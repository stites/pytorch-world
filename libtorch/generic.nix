{ stdenv, fetchzip, autoreconfHook, gettext
, version, sha256
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

# stable cuda 10 doesn't exist yet
assert cudaSupport == false || (cudatoolkit != null && cudnn != null && cudaMajor == "9" && cudaMinor == "0");
assert mklSupport == false || mkl != null;
assert version == "1.1" || version == "nightly";

stdenv.mkDerivation rec {
  name = "libtorch-${version}";
  inherit version;

  src = fetchzip {
    # url = "https://download.pytorch.org/libtorch/${buildtype}/libtorch-shared-with-deps-latest.zip";
    url = "https://download.pytorch.org/libtorch/${buildtype}/libtorch-macos-1.1.0.zip";
    inherit sha256;
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

  # postInstall = ''
  #   # Make boost header paths relative so that they are not runtime dependencies
  #   cd "$dev" && find include \( -name '*.hpp' -or -name '*.h' -or -name '*.ipp' \) \
  #     -exec sed '1i#line 1 "{}"' -i '{}' \;
  # '';

  meta = with stdenv.lib; {
    description = "libtorch";
    homepage = https://pytorch.org/;
    license = licenses.bsd3;
    platforms = with platforms; platforms.all; #[ linux ] ++ stdenv.lib.optionals (!cudaSupport) [ darwin ];
  };
}
