{ stdenv, fetchzip, useIomp5
}:

stdenv.mkDerivation rec {
  name = "libmklml";
  version = "1.7.0";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchzip {
        url = "https://github.com/oneapi-src/oneDNN/releases/download/v1.7/dnnl_lnx_1.7.0_cpu_iomp.tgz";
        sha256 = "0dd82xxr66w7gsgyr3jyq05vdyl2f6xncng33d3a9kvm01rnyin6";
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchzip {
        url = "https://github.com/oneapi-src/oneDNN/releases/download/v1.7/dnnl_mac_1.7.0_cpu_iomp.tgz";
        sha256 = "1vdqfg9fnpn4hzx13wcdb8cwfql98kw9rz6bchidnb01swg0m13i";
      }
    else throw "missing url for platform ${stdenv.hostPlatform.system}";

  preFixup =
    stdenv.lib.optionalString (!useIomp5) ''
    rm $out/lib/libiomp5.*
    '' + 
    stdenv.lib.optionalString stdenv.isDarwin (''
    echo "-- before fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
    for f in $(ls $out/lib/*.dylib); do
        install_name_tool -id @rpath/$(basename $f) $f || true
    done
  '' + (stdenv.lib.optionalString useIomp5
  ''
    install_name_tool -change @rpath/libiomp5.dylib $out/lib/libiomp5.dylib $out/lib/libmklml.dylib
  '')
    +
  ''
    echo "-- after fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
  '');

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
