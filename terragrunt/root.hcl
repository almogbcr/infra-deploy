terraform_binary = "tofu"

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  disable   = basename(get_terragrunt_dir()) == "addons"

  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "${get_env("AWS_REGION")}"
}
EOF
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket       = get_env("TF_STATE_BUCKET")
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = get_env("AWS_REGION")
    encrypt      = true
    use_lockfile = true
  }
}