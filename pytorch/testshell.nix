{ pkgs ? import ../pin/nixpkgs.nix { }, python ? pkgs.python3 }:

let
  inherit (import ./generic.nix { inherit pkgs python; }) unstableGenericPython;
  python-unstable = unstableGenericPython ./unstable-pins/v1.4.0a0-2019-12-17.json "1.4.0a0" {
     mklSupport = false;
     cudaSupport = false;
     buildBinaries = false;
     openMPISupport = false;
   };
in

pkgs.mkShell {
  buildInputs = [ (python-unstable.withPackages(ps: with ps; [ pytorch hypothesis ])) pkgs.ninja ];
}
