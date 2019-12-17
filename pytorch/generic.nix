{ pkgs, python }:

with pkgs.lib.attrsets;
with builtins;

rec {
  genericPython = args: unstableGeneric null null args;
  unstableGenericPython = pinpath: unstable-version: args:
    let
      unstable = fromJSON (readFile pinpath);
      shortsha = substring 0 7 unstable.rev;
      mypython = python.override {
        packageOverrides = self: super: rec {
          numpy = if (hasAttr "mklSupport" args && args.mklSupport)
                  then super.numpy.override { blas = pkgs.mkl; }
                  else super.numpy;
          stablept = (self.callPackage ./. ({ } // args));
          pytorch =
            if pinpath == null then stablept
            else stablept.overrideAttrs(old: {
              version = unstable-version;
              name = "pytorch-${unstable-version}";
              PYTORCH_BUILD_VERSION = unstable-version;
              doCheck = true; # always run tests on unstable packages
              src = pkgs.fetchFromGitHub {
                owner  = "pytorch";
                repo   = "pytorch";
                rev    = unstable.rev;
                fetchSubmodules = true;
                sha256 = unstable.sha256;
              };
            });
        };
        self = mypython;
      };
    in mypython;
  generic = args: (generic args).withPackages(ps: [ps.pytorch]);
  unstableGeneric = pinpath: unstable-version: args: (unstableGeneric pinpath unstable-version args).withPackages(ps: [ps.pytorch]);
}

