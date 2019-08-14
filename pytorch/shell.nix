{ pkgs ? import ../pin/nixpkgs.nix { } }:

let
  python36With =
    let
      mypython = pkgs.python36.override {
        packageOverrides = self: super: {
          pytorch = (pkgs.callPackage ./release.nix { inherit pkgs; pythonPackages = pkgs.python36Packages; }).pytorch;
        };
        self = mypython;
      };
    in mypython.withPackages(ps: [ ps.pytorch ]);
in

pkgs.mkShell {
  buildInputs = [ python36With ];
}
