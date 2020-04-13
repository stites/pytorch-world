{ pkgs ? import ../pin/nixpkgs.nix {} }:

with pkgs;

let
  libmklml = opts: callPackage ./mklml.nix ({
  } // opts);
  callCpu = opts: callPackage ./generic.nix ({
    mklml = libmklml { useIomp5 = stdenv.hostPlatform.system != "x86_64-darwin";};
    libcxx = libcxx;
  } // opts);
  callGpu = opts: callPackage ./generic.nix ({
    mklml = libmklml { useIomp5 = stdenv.hostPlatform.system != "x86_64-darwin";};
    libcxx = libcxx;
  } // opts);
in
{
  libmklml = libmklml { useIomp5 = true; };
  libmklml_without_iomp5 = libmklml { useIomp5 = false; };
  libtorch_cpu = callCpu {
    version = "1.4";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.4.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.4.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "1bbvsmm29hf0xf6zw6y34cd8ds49wp6n0jg773bpc6735xcycihn";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.4.0.zip";
          sha256 = "0r6p8k4k28npczq6wj3jj0zgfglys3jilhln5hy75bp8a4w8jix6";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.4";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.4.0.zip";
          sha256 = "0cnix6lz257q9nrvzl45ya2r6slfk6w5kxag6b19drsynvyr8zw8";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.4";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.4.0%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.4.0/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0fd3i6p2c406phkgjijhdv33r1bk9aijvx5p0xf3hgf8h90z08sj";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
