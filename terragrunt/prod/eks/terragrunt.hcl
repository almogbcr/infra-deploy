include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../terraform/modules/eks"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-00000001", "subnet-00000002"]
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

inputs = {
  env                = "prod"
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  api_access_cidrs   = [get_env("EKS_API_CIDR")]
  instance_types     = ["t3.medium"]
  desired_size       = 2
  min_size           = 2
  max_size           = 2
}