{ stdenv, fetchzip, autoreconfHook, gettext
, version ? "1.8", mkSrc, buildtype
, libcxx ? null
}:

stdenv.mkDerivation rec {
  name = "libtorch-${version}";
  inherit version;

  src = mkSrc buildtype;
  libcxxPath  = libcxx.outPath;

  propagatedBuildInputs = if stdenv.isDarwin then [ libcxx ] else [];
  preFixup = stdenv.lib.optionalString stdenv.isDarwin ''
    echo "-- before fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
    for f in $(ls $out/lib/*.dylib); do
      install_name_tool -id $out/lib/$(basename $f) $f || true
      for rpath in $(otool -L $f | grep rpath | awk '{print $1}');do
        install_name_tool -change $rpath $out/lib/$(basename $rpath) $f
      done
      if otool -L $f | grep /usr/lib/libc++ >& /dev/null ;then
        install_name_tool -change /usr/lib/libc++.1.dylib  $libcxxPath/lib/libc++.1.0.dylib $f
      fi
    done
    echo "-- after fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
  '';
  installPhase = ''
    ls $src
    mkdir $out
    if [ -d $src/bin ] ; then
      cp -r {$src,$out}/bin/
    fi
    cp -r {$src,$out}/include/
    cp -r {$src,$out}/lib/
    cp -r {$src,$out}/share/
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "libtorch";
    homepage = https://pytorch.org/;
    license = licenses.bsd3;
    platforms = with platforms; linux ++ darwin;
  };
}
