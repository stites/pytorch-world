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
    version = "1.7";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.7.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.7.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0jdd7bjcy20xz2gfv8f61zdrbzxz5425bnqaaqgrwpzvd45ay8px";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.7.0.zip";
          sha256 = "1912lklil0i7i10j1fm4qzcq96cc8c281l9fn5gfbwa2wwry0r59";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_11_0"} = callGpu {
    version = "cu110-1.7";
    buildtype = "cu110";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.7.0/cu110-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0nlzbfvihib64gfai5k2dsgdaw100p79bcrsnjdilfsyb37lvf6q";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_2"} = callGpu {
    version = "cu102-1.7";
    buildtype = "cu102";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.7.0.zip";
          sha256 = "1ag6lvf3a400ivqq4g9cxpmxzlfrga0y5ssjy0rfpw6i1xljibn6";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.7";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.7.0%2Bcu101.zip".
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.7.0/cu101-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "13dcylmbyfha3sy3xl67v4vsqjr0caljv5a7a08xdsi10addyysf";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.7";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.7.0%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.7.0/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "15hrd1j77dhjl6jyjkasx9j2x6gk7vrw43b90g3y3b46x5a0cnkb";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
