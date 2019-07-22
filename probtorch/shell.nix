{ pkgs ? import ../pin/nixpkgs.nix { } }:

let
  python36With =
    let
      mypython = pkgs.python36.override {
        packageOverrides = self: super: let
          pytorch = (pkgs.callPackage ../pytorch/release.nix { inherit pkgs; pythonPackages = pkgs.python36Packages; }).pytorchWithCuda10;
          probtorch = pkgs.callPackage ./. { inherit (pkgs.python36Packages) buildPythonPackage; inherit pytorch; };
        in { inherit pytorch probtorch; };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.probtorch ps.bokeh ]);
in

python36With.env

