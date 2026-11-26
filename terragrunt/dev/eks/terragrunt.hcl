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
  env                = "dev"
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  api_access_cidrs   = [get_env("EKS_API_CIDR")]
  instance_types     = ["m7i-flex.large"]
  desired_size       = 1
  min_size           = 1
  max_size           = 1
  secret_names = [
    "dev/flask/api-key",
    "staging/flask/api-key"
  ]
}