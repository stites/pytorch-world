#include<torch/torch.h>
#include<iostream>

int main(){
  // build a 2-D (3,3) Tensor
  at::Tensor mat = torch::rand({3,3});
  at::Tensor identity = torch::ones({3,3});
  std::cout << mat << std::endl;
  std::cout << mat * identity << std::endl;
}
