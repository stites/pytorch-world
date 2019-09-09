pytorch-world
=============
<h4>Stable snapshots of the pytorch ecosystem can be found in releases.</h4>

The pytorch ecosystem, from a single nix-user's perspective, as I get around to building it.
Any user-submitted packages are welcome : ).

Releases
============================

This repository will tag releases according to the working version of pytorch.
There will also a post-fixed snapshot number when new packages are working.
All releases will only be tested for python-3.6 unless otherwise noted.

- `unstable`:
  - darwin support for `dev` outputs
  - disabled test phase (for faster builds). Override `doCheck` to run the test suite. 
  - adds a cudaArchList argument that allows users to test on the latest nvidia hardware without waiting for this package.
  - adds .dev output which gives top-level access to generated C/C++ code (libtorch).

- `v1.2.0-1`:
  - runs all tests except for utils
  - adds mkl support to magma-2.5.0
  - adds cuda support to openMPI
  - adds openMPI support
  - allows users to build NamedTensors
  - allows users to get access to generated binaries from build process
  - adds darwin support if cudaSupport is disabled.
  - packages: (+probtorch)

- `v1.1.0`
  - builds without FBGEMM
  - packages: None


Features
=============

The current features are supported:

| **Python-3.6.9 support**            | pytorch-v1.1.0     | pytorch-v1.2.0     |
| ----------------------------------- | ------------------ | ------------------ |
| vanilla                             | :heavy_check_mark: | :heavy_check_mark: |
| mkl+mkldnn                          | :heavy_check_mark: | :heavy_check_mark: |
| openMPI                             | :heavy_check_mark: | :heavy_check_mark: |
| FBGEMM                              | :x:                | :heavy_check_mark: |
| Full CPU (all above)*               | :heavy_check_mark: | :heavy_check_mark: |
| Full CPU + NamedTensors + Binaries  | :grey_exclamation: | :heavy_check_mark: |
| CUDA                                | :heavy_check_mark: | :heavy_check_mark: |
| CUDA+NCCL                           | :heavy_check_mark: | :heavy_check_mark: |
| CUDA+NCCL+openMPI                   | :heavy_check_mark: | :heavy_check_mark: |
| CUDA+NCCL+openMPI+mkl               | :heavy_check_mark: | :heavy_check_mark: |
| Full CUDA (all above)*              | :heavy_check_mark: | :heavy_check_mark: |
| Full CUDA + NamedTensors + Binaries | :grey_exclamation: | :heavy_check_mark: |

The ":grey_exclamation:" means that namedtensors and binaries weren't attempted in pytorch-v1.1.0.

The "*" implies that FBGEMM is not included in any of the "Full" builds in pytorch-v1.1.0, but is included for all of pytorch-v1.2.0


Using this in your projects
============================

Suggested use is to pull in `pytorch-world` as a git submodule under some `nix/` folder and refer to `probtorch/release.nix` for an example of how to depend on this library.
Do not reference `release.nix` files as they don't generate site-packages and only output final python binaries.

Cachix
=============

Binaries can be found at [pytorch-world.cachix.org](https://pytorch-world.cachix.org)

Currently, you will find binaries for the `./release.nix` file which includes pytorch-1.2-related builds.
This covers all CPU builds, which are darwin-accessible, as well as cuda-enabled pytorch built with `cudatoolkit_10_0`, and `libtorch` built with CUDA-9 and CPU.
This was built on NixOS with python-3.6 (pin located at `./pin/`), please file issues to help support!
You can retrieve any of these with the following:

```
cachix use pytorch-world
nix-build ./release.nix -A pytorch -A pytorch36-mkl -A pytorch36-cu
```

