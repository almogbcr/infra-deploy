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

## Repository Access

Argo CD reads the public GitHub repository over HTTPS.

## Application Configuration

Each application tracks a full Git commit SHA containing its Helm chart
and environment configuration. Its image repository and digest are supplied
as Helm parameters in the Application manifest.

| Environment | Git Revision | Values File | Namespace |
|-------------|--------------|-------------|-----------|
| Development | Pinned commit SHA | values-dev.yaml | dev |
| Staging | Pinned commit SHA | values-staging.yaml | staging |
| Production | Pinned commit SHA | values-prod.yaml | production |

Root Applications track main and synchronize the child Application manifests.
The manual Promotion workflow updates a selected child's revision and image
parameters through a Pull Request. Chart and configuration changes on main
reach an environment only after its pinned revision is updated.

Root and child Application manifests are administrative configuration:
changes to them can change what is deployed. Protect these paths and main
through repository review rules. All Applications currently use the default
Argo CD project; separate project restrictions are not implemented.

Automatic synchronization is enabled in all environments.

Self-heal is enabled to restore the desired configuration
if manual changes are made inside Kubernetes.

Namespaces are created automatically by Argo CD.

ALB Pod Readiness Gates are enabled using namespace labels
to improve application availability during rolling updates.


## Management Access

Argo CD has no management Ingress configured. Access requires Kubernetes
API connectivity and appropriate permissions. For browser access from the
administrator's machine:

```bash
kubectl --context dev-eks -n argocd port-forward svc/argocd-server 8080:443 --address 127.0.0.1
```

Open `https://localhost:8080`. Use `prod-eks` for the production cluster.
Keep the command running during the session. The default server certificate
may produce a browser warning. No public management endpoint is created.

## Rollback

Open a PR restoring the affected Application's previous `targetRevision`,
`app.image.imageRepo` and `app.image.imageDigest` together. Merge it after
review; automated synchronization applies the previous release.

Keep the referenced Git commit and image digest available. Database or
external-service changes, if introduced later, require their own rollback
strategy.
