{ stdenv, fetchzip
}:

stdenv.mkDerivation rec {
  name = "libmklml";
  version = "0.17.2";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchzip {
        url = "https://github.com/intel/mkl-dnn/releases/download/v0.17.2/mklml_lnx_2019.0.1.20181227.tgz";
        sha256 = "0g9fd97pcbzsfslj8j517jwl2rflqqsph3dny553pw62gqiy92gr";
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchzip {
        url = "https://github.com/intel/mkl-dnn/releases/download/v0.17.2/mklml_mac_2019.0.1.20181227.tgz";
        sha256 = "01vbvp1khd118rskcaszwl0vw7z30bnwqcs88ah4fj1i9q5k7z7k";
      }
    else throw "missing url for platform ${stdenv.hostPlatform.system}";

  preFixup = stdenv.lib.optionalString stdenv.isDarwin ''
    echo "-- before fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
    for f in $(ls $out/lib/*.dylib); do
        install_name_tool -id @rpath/$(basename $f) $f || true
    done
    install_name_tool -change @rpath/libiomp5.dylib $out/lib/libiomp5.dylib $out/lib/libmklml.dylib
    echo "-- after fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
  '';

  installPhase = ''
    ls $src
    mkdir $out
    cp -r {$src,$out}/include/
    cp -r {$src,$out}/lib/
  '';

  meta = with stdenv.lib; {
    description = "libmklml";
    homepage = https://software.intel.com/en-us/mkl;
    license = { free = false; fullName = "Intel Simplified Software License"; shortName = "issl"; url = "https://software.intel.com/en-us/license/intel-simplified-software-license"; };
    platforms = with platforms; linux ++ darwin;
  };
}
