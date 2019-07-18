{ pkgs ? import ../pin/nixpkgs.nix {} }:

let
  mypackageOverrides = gpu: self: super:
    let
      pytorch36-cpu = (self.callPackage ../pytorch/release.nix {}).pytorch36-vanilla;
      pytorch36-cu = (self.callPackage ../pytorch/release.nix {}).pytorch36-cu;
      pytorch = if gpu then pytorch36-cu else pytorch36-cpu;
      probtorch = self.callPackage ./. { inherit (pkgs.python36Packages) buildPythonPackage; inherit pytorch; };
    in
      { inherit probtorch pytorch; };

  generic36 = { gpu }:
    let
      mypython = pkgs.python36.override {
        packageOverrides = mypackageOverrides gpu;
        self = mypython;
      };
    in mypython.withPackages (ps: [ ps.pytorch ps.probtorch ]);
in
{
  probtorch36-cpu = generic36 { gpu = false; };
  probtorch36-cu = generic36 { gpu = true; };
}

