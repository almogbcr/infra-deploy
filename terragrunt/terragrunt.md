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
* Terraform local backend configuration.

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

Each Terragrunt unit has its own local Terraform State file.

State files are excluded from Git to avoid exposing
sensitive infrastructure information.

A remote backend would be preferred in a shared
production environment.