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
    version = "1.8";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.8.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.8.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "15vnfdy5m4x3b39ayr22frk0n15d4wx23k5i0b90k2fyiv48s5n4";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.8.0.zip";
          sha256 = "109c85kjm71d9jzir2ha7w6k97f02ny2cqipb8rdrlq1sg75nnap";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_11_1"} = callGpu {
    version = "cu111-1.8";
    buildtype = "cu111";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.8.0/cu111-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0k9gg9cyvsij61lpq0iakdz432rnya8vrj134ms058xkxfsfj3mr";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_2"} = callGpu {
    version = "cu102-1.8";
    buildtype = "cu102";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.8.0.zip";
          sha256 = "1qri5f5krdbl1vkx6g7lhhcmjjkgg63ka6jdf7xyazd3iw9k5ldc";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_rocm"} = callGpu {
    version = "rocm-1.8";
    buildtype = "rocm";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.8.0/rocm-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0i142x77zh654lk3zqfrchsl9cjmdp7z00asr14zxbx05yvfl4hh";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
