pytorch-world
=============

The pytorch ecosystem in nix.

Pytorch-1.x support is still being solidified. The current features are supported:

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


Cachix (status: complicated)
============================

Binaries are to appear at pytorch-world.cachix.org.

Currently, you will find pytorch36, pytorch36-mkl, and pytorch36-cu pushed to cachix. You can get them from this project root with the following:

```
cachix use pytorch-world
nix-build ./pytorch/release.nix -A pytorch36 -A pytorch36-mkl -A pytorch36-cu
```



