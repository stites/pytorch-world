{ callPackage }:

let generic = { version, sha256 }:
  callPackage (import ./generic.nix { inherit version sha256; }) {};
in
{
  googletest_181 = generic {
    version = "1.8.1";
    sha256 = "0bjlljmbf8glnd9qjabx73w6pd7ibv43yiyngqvmvgxsabzr8399";
  };
  googletest_180 = generic {
    version = "1.8.0";
    sha256 = "0bjlljmbf8glnd9qjabx73w6pd7ibv43yiyngqvmvgxsabzr8399";
  };
}
