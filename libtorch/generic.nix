{ stdenv, fetchzip, autoreconfHook, gettext
, version ? "1.4", mkSrc, buildtype
, mklml ? null
, libcxx ? null
}:

stdenv.mkDerivation rec {
  name = "libtorch-${version}";
  inherit version;

  src = mkSrc buildtype;
  mklmlPath  = mklml.outPath;
  libcxxPath  = libcxx.outPath;

  propagatedBuildInputs = if stdenv.isDarwin then [ mklml libcxx ] else [];
  patches = [./Dispatcher.patch];
  preFixup = stdenv.lib.optionalString stdenv.isDarwin ''
    echo "-- before fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
    for f in $(ls $out/lib/*.dylib); do
      install_name_tool -id $out/lib/$(basename $f) $f || true
    done
    install_name_tool -change @rpath/libshm.dylib $out/lib/libshm.dylib $out/lib/libtorch_python.dylib
    install_name_tool -change @rpath/libtorch.dylib $out/lib/libtorch.dylib $out/lib/libtorch_python.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libtorch_python.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libtorch.dylib
    install_name_tool -change @rpath/libtorch.dylib $out/lib/libtorch.dylib $out/lib/libcaffe2_observers.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libcaffe2_observers.dylib
    install_name_tool -change @rpath/libtorch.dylib $out/lib/libtorch.dylib $out/lib/libcaffe2_module_test_dynamic.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libcaffe2_module_test_dynamic.dylib
    install_name_tool -change @rpath/libtorch.dylib $out/lib/libtorch.dylib $out/lib/libcaffe2_detectron_ops.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libcaffe2_detectron_ops.dylib
    install_name_tool -change @rpath/libtorch.dylib $out/lib/libtorch.dylib $out/lib/libshm.dylib
    install_name_tool -change @rpath/libc10.dylib $out/lib/libc10.dylib $out/lib/libshm.dylib

    for i in libtorch.dylib libcaffe2_detectron_ops.dylib libcaffe2_module_test_dynamic.dylib libcaffe2_observers.dylib libshm.dylib libtorch_python.dylib ; do 
      install_name_tool -change @rpath/libmklml.dylib $mklmlPath/lib/libmklml.dylib $out/lib/$i
      install_name_tool -change @rpath/libiomp5.dylib $mklmlPath/lib/libiomp5.dylib $out/lib/$i
      install_name_tool -change /usr/lib/libc++.1.dylib $libcxxPath/lib/libc++.1.0.dylib $out/lib/$i
    done
    install_name_tool -change /usr/lib/libc++.1.dylib $libcxxPath/lib/libc++.1.0.dylib $out/lib/libc10.dylib
    echo "-- after fixup --"
    for f in $(ls $out/lib/*.dylib); do
        otool -L $f
    done
  '';
  installPhase = ''
    ls $src
    mkdir $out
    cp -r {$src,$out}/bin/
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
