# { pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python36, pythonPackages ? pkgs.python36Packages }:
{ pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python3 }:

let
  pythonWith =
    let
      mypython = python.override {
        packageOverrides = self: super: {
          pytorch = super.callPackage ./. { };
        };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ps.tensorflow-tensorboard]);
in

pkgs.mkShell {
  buildInputs = [ pythonWith ];
}
