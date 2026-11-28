# Argo CD

## Overview

Argo CD is a GitOps tool that manages application deployments
by synchronizing the configuration from Git to Kubernetes.

In our project, Argo CD deploys the application using
a Helm Chart with separate values files for each environment.

## App of Apps Architecture

We use the App of Apps approach, where a parent application
manages multiple child applications.

Each EKS cluster has its own root application.

- DEV Cluster - Manages Development and Staging applications.
- PROD Cluster - Manages the Production application.

## Repository Authentication

Argo CD connects to GitHub using a GitHub App with read-only
repository permissions instead of an SSH Deploy Key.

The private key is stored outside the Git repository.

## Application Configuration

Each application is configured with its own Git branch,
Helm values file and destination namespace.

| Environment | Branch | Values File | Namespace |
|-------------|--------|-------------|-----------|
| Development | dev | values-dev.yaml | dev |
| Staging | main | values-staging.yaml | staging |
| Production | main | values-prod.yaml | production |

Automatic synchronization is enabled in all environments.

Self-heal is enabled to restore the desired configuration
if manual changes are made inside Kubernetes.

Namespaces are created automatically by Argo CD.

ALB Pod Readiness Gates are enabled using namespace labels
to improve application availability during rolling updates.