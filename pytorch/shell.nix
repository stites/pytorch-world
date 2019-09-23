# { pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python36, pythonPackages ? pkgs.python36Packages }:
{ pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python3 }:

let
  pythonWith =
    let
      mypython = python.override {
        packageOverrides = self: super: rec {
          pytorch = super.callPackage ./. { };
        };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ]);
in

pkgs.mkShell {
  buildInputs = [ pythonWith ];
}
