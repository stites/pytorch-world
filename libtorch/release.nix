{ pkgs ? import ../pin/nixpkgs.nix {} }:

with pkgs;

let
  libmklml = opts: callPackage ./mklml.nix ({
  } // opts);
  callCpu = opts: callPackage ./generic.nix ({
    libcxx = libcxx;
  } // opts);
  callGpu = opts: callPackage ./generic.nix ({
    libcxx = libcxx;
  } // opts);
in
{
  libmklml = libmklml { useIomp5 = true; };
  libmklml_without_iomp5 = libmklml { useIomp5 = false; };
  libtorch_cpu = callCpu {
    version = "1.5";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.5.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.5.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "1acz4n7d8k0cjlrysjmls05sdj9klwh0j603pdb2qdq5abclm3dl";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.5.0.zip";
          sha256 = "1hrhpy4yn8z5sjqwafib2wnla5isx7cg586qv1cbpdcl4am6z8v7";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_2"} = callGpu {
    version = "cu102-1.5";
    buildtype = "cu102";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.5.0.zip";
          sha256 = "1ps8k2qgw5jrzv3gbsaw301ipvakflnmgh3nv5ppaanxdybdadlp";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.5";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.5.0%2Bcu101.zip".
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.5.0/cu101-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0712ix9inwijzq23k3ac58imlqj1y4x93i2k4hv1md44jhbz06zr";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.5";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.5.0%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.5.0/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "00vnbc3sv4gdmvic7nvf3jr1mmaf2gms3r4q6ifsskahyinxhyxl";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
