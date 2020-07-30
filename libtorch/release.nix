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
    version = "1.6";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.6.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.6.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "1975b4zvyihzh89vnwspw0vf9qr05sxj8939vcrlmv3gzvdspcxz";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.6.0.zip";
          sha256 = "0d4n7la31qzl4s9pwvm07la7q6lhcwiww0yjpfz3kw6nvx84p22r";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_2"} = callGpu {
    version = "cu102-1.6";
    buildtype = "cu102";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.6.0.zip";
          sha256 = "127qnfyi1faqbm40sbnsyqxjhrqj82bzwqyz7c1hs2bm0zgrrpya";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.6";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.6.0%2Bcu101.zip".
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.6.0/cu101-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0syxsdca42ns00x4gy9pwlxhw81vhc3575agl8siwl96nmb25794";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.6";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.6.0%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.6.0/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "11nirp7j380fylgjpcxdd9nac2bwrxwf3wkwzdj4ajmswirgwxxm";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
