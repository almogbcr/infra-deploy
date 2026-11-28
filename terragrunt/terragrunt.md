# Terragrunt

## Overview

Terragrunt is used to manage Terraform configurations
and dependencies between infrastructure modules.

It allows us to reuse the same Terraform modules
across different environments without duplicating the code.

## Directory Structure

```
terragrunt/
├── root.hcl
├── dev/
│   ├── network/
│   ├── eks/
│   └── addons/
└── prod/
    ├── network/
    ├── eks/
    └── addons/
```

## Shared Configuration

The root.hcl file contains the shared Terraform configuration.

* AWS Provider configuration.
* Terraform S3 remote backend configuration with state locking.

The AWS region is provided through an environment variable.

## Environment Configuration

Each environment has its own terragrunt.hcl files
with environment-specific inputs, such as:

* VPC and subnet CIDRs.
* EC2 instance types.
* Number of Worker Nodes.
* EKS API access CIDRs.
* Secret names.

## Dependencies

Terragrunt manages dependencies between the modules.

Deployment order:

```
Network -> EKS -> Add-ons
```

The EKS module receives subnet IDs from the Network module.

The Add-ons module receives the cluster configuration
and VPC ID from the EKS and Network modules.

During infrastructure destruction, Terragrunt uses
the reverse dependency order.

```
Add-ons -> EKS -> Network
```

Application resources must be removed before destroying
the Kubernetes controllers and infrastructure.

## State Management

Each Terragrunt unit stores state in S3 under its own key:
`<environment>/<unit>/terraform.tfstate`.

The bucket name and AWS region are supplied through `TF_STATE_BUCKET` and
`AWS_REGION`. Encryption and S3 lock files (`use_lockfile = true`) are enabled
in `root.hcl`. Terragrunt is configured to run Terraform explicitly.

Local state files and caches are excluded from Git. Cleanup intentionally
retains the S3 state bucket.
