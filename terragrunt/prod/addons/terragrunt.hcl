include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../terraform/modules/addons"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name           = "mock-eks"
    cluster_endpoint       = "https://example.com"
    cluster_ca_certificate = base64encode("mock-ca")
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "vpc-00000001"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

inputs = {
  cluster_name           = dependency.eks.outputs.cluster_name
  cluster_endpoint       = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_ca_certificate

  aws_region           = get_env("AWS_REGION")
  argocd_chart_version = "10.10.5"
  argocd_values        = file("../../../argocd/prod-cluster/helm-values.yaml")

  vpc_id = dependency.network.outputs.vpc_id
}