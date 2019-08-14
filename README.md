pytorch-world
=============

The pytorch ecosystem in nix

Cachix (status: complicated)
============================

Binaries are to appear at pytorch-world.cachix.org.

Currently, you will find pytorch36, pytorch36-mkl, and pytorch36-cu pushed to cachix. You can get them from this project root with the following:

```
cachix use pytorch-world
nix-build ./pytorch/release.nix -A pytorch36 -A pytorch36-mkl -A pytorch36-cu
```



