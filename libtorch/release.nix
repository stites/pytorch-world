{ pkgs ? import ../pin/nixpkgs.nix {} }:

with pkgs;

let
  libmklml = opts: callPackage ./mklml.nix ({
  } // opts);
  callCpu = opts: callPackage ./generic.nix ({
    mklml = libmklml {};
    libcxx = libcxx;
  } // opts);
  callGpu = opts: callPackage ./generic.nix ({
    mklml = libmklml {};
    libcxx = libcxx;
  } // opts);
in
{
  libmklml = libmklml {};
  libtorch_cpu = callCpu {
    version = "1.3";
    buildtype = "cpu";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.3.0%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.3.0/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0xkbhrgfl4zfp70zxssvigq9yns7pfczwa09ayxkqjnq8hr1i32n";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.3.0.zip";
          sha256 = "11rwa8hxxs0n48qq91z8hi29l484js7ajxc34i58s7lxspw7hdaf";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.3";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.3.0.zip";
          sha256 = "0wbhab2gy3wmsni3nm3z15kw3w579ah68b2ikngxdrgw77z1rqr7";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.3";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.3.0%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.3.0/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "1xda0bkh7sgdcsng8vajs8rsg6xpdajvm1ycksrmi4jd8ifl772d";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
