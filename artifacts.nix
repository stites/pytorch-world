{ pkgs ? import ./pin/nixpkgs.nix {} }:

{
  pytorch36 = import ./release.nix { inherit pkgs; python = pkgs.python36; pythonPackages = pkgs.python36Packages; };
  pytorch37 = import ./release.nix { inherit pkgs; python = pkgs.python37; pythonPackages = pkgs.python37Packages; };
}
