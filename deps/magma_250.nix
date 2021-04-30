{ stdenv, fetchurl, cmake, gfortran, cudatoolkit, libpthreadstubs, liblapack
, mklSupport ? false, mkl ? null
}:

assert !mklSupport || mkl != null;

with stdenv.lib;

let version = "2.5.2";

in stdenv.mkDerivation {
  name = "magma-${version}";
  src = fetchurl {
    url = "https://icl.cs.utk.edu/projectsfiles/magma/downloads/magma-${version}.tar.gz";
    sha256 = "0azh9qiqhfpz50faxpr4dqa7zdx224nj32x0cpgvq7ygnn4wk0i5";
    name = "magma-${version}.tar.gz";
  };

  buildInputs = [ gfortran cudatoolkit libpthreadstubs cmake ]
    ++ (if mklSupport then [ mkl ] else [ liblapack ]);

  doCheck = false;

  MKLROOT = optionalString mklSupport "${mkl}";

  #checkTarget = "tests";

  enableParallelBuilding=true;

  preConfigure = ''
    export CC=${cudatoolkit.cc}/bin/gcc CXX=${cudatoolkit.cc}/bin/g++
  '';

  # we will not build tests as erroring on compilation
  buildPhase = ''
    runHook preBuild
    # set to empty if unset
    : ''${makeFlags=}
    local flagsArray=(
        ''${enableParallelBuilding:+-j''${NIX_BUILD_CORES} -l''${NIX_BUILD_CORES}}
        SHELL=''$SHELL
        ''$makeFlags ''${makeFlagsArray+"''${makeFlagsArray[@]}"}
        ''$buildFlags ''${buildFlagsArray+"''${buildFlagsArray[@]}"}
    )
    echoCmd 'build flags' "''${flagsArray[@]}"
    make magma "''${flagsArray[@]}"
    make magma_sparse "''${flagsArray[@]}"
    unset flagsArray
    runHook postBuild
  '';
# MAGMA's default CMake setup does not care about installation. So we copy files directly.
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/include
    mkdir -p $out/lib
    mkdir -p $out/lib/pkgconfig
    cp -a ../include/*.h $out/include
    #cp -a sparse-iter/include/*.h $out/include
    cp -a lib/*.a $out/lib
    cat ../lib/pkgconfig/magma.pc.in                   | \
    sed -e s:@INSTALL_PREFIX@:"$out":          | \
    sed -e s:@CFLAGS@:"-I$out/include":    | \
    sed -e s:@LIBS@:"-L$out/lib -lmagma -lmagma_sparse": | \
    sed -e s:@MAGMA_REQUIRED@::                       \
        > $out/lib/pkgconfig/magma.pc
  '';

  meta = with stdenv.lib; {
    description = "Matrix Algebra on GPU and Multicore Architectures";
    license = licenses.bsd3;
    homepage = http://icl.cs.utk.edu/magma/index.html;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ianwookim ];
  };
}
