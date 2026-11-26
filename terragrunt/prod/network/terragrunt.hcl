include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../terraform/modules/network"
}

inputs = {
  env            = "prod"
  vpc_cidr       = "10.0.16.0/20"
  subnet_private = ["10.0.16.0/24", "10.0.17.0/24"]
  subnet_public  = ["10.0.18.0/24", "10.0.19.0/24"]
}