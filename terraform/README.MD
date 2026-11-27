# Terraform

## Overview

Terraform is used to create and manage the AWS infrastructure
using Infrastructure as Code (IaC).

The infrastructure is divided into reusable modules, allowing
us to use the same code for DEV and PROD with different configurations.

## Module Structure

```
terraform/
└── modules/
    ├── network/
    ├── eks/
    └── addons/
```

## Network Module

The network module creates the AWS networking infrastructure:

* VPC
* Public and private subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Elastic IP

Each environment has its own VPC.

The subnets are distributed across two Availability Zones.

Worker Nodes are deployed in private subnets and use
the NAT Gateway for outgoing internet access.

## EKS Module

The EKS module creates and configures:

* Amazon EKS Cluster
* Managed Node Group
* IAM Roles and Policies
* EKS Add-ons
* AWS Secrets Manager secrets

Network Policy support is enabled through the AWS VPC CNI.

Production is configured with two Worker Nodes to improve
application availability.

Terraform creates the Secrets Manager resources without
defining their secret values.

## Add-ons Module

The add-ons module uses the Terraform Helm Provider
to install the following tools in each EKS cluster:

* Argo CD
* External Secrets Operator
* AWS Load Balancer Controller

The modules are configured and executed using Terragrunt.