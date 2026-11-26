include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../terraform/modules/network"
}

inputs = {
  env            = "dev"
  vpc_cidr       = "10.0.0.0/20"
  subnet_private = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_public  = ["10.0.2.0/24", "10.0.3.0/24"]

  internal_alb_subnets = [
  "10.0.4.0/24",
  "10.0.5.0/24"
]
}