{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  googletest-all = callPackage ./googletest {};
  googletest_180 = googletest-all.googletest_180;
  googletest_181 = googletest-all.googletest_181;
  googlebenchmark = callPackage ./googlebenchmark.nix {};

  asmjit = callPackage ./asmjit.nix {};
  cpuinfo = callPackage ./cpuinfo.nix {
    inherit googlebenchmark;
    googletest = googletest_180;
  };
in
{
  inherit asmjit cpuinfo googletest googletest_180 googletest_181 googlebenchmark;
  fbgemm = callPackage ./fbgemm.nix { inherit asmjit cpuinfo googletest; };
}
