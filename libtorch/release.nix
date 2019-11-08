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
          # Source file is  "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.3.1%2Bcpu.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.3.1/cpu-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "1v76l70wsyal8d41w00mnhg9ykd647z1a5h545x02wfi1d9cmanw";
        }
      else if stdenv.hostPlatform.system == "x86_64-darwin" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.3.1.zip";
          sha256 = "0picyiywgqa1l8qcvij381d6z0lbpn864br2rzsw1g8g6rg6invg";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_10_1"} = callGpu {
    version = "cu101-1.3";
    buildtype = "cu101";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          url = "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.3.1.zip";
          sha256 = "1rxpgwi88pi42g8881nlyqdhmzjl51iax7hv93x4wd99iwdd1yva";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
  ${if stdenv.hostPlatform.system == "x86_64-darwin" then null else "libtorch_cudatoolkit_9_2"} = callGpu {
    version = "cu92-1.3";
    buildtype = "cu92";
    mkSrc = buildtype:
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchzip {
          # Source file is "https://download.pytorch.org/libtorch/cu92/libtorch-cxx11-abi-shared-with-deps-1.3.1%2Bcu92.zip".
          # Nix can not use the url directly, because this link includes '%2B'.
          url = "https://github.com/hasktorch/libtorch-binary-for-ci/releases/download/1.3.1/cu92-libtorch-cxx11-abi-shared-with-deps-latest.zip";
          sha256 = "0kxknm8kvvxw98hy1f5nb6wxbv68ass2iq72qcsf75xd96q208d2";
        }
      else throw "missing url for platform ${stdenv.hostPlatform.system}";
  };
}
