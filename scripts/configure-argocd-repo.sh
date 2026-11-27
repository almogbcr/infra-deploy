#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${1:?Usage: $0 <kube-context>}"

REPO_URL="${ARGOCD_REPO_URL:?Missing repository URL}"
APP_ID="${GITHUB_APP_ID:?Missing GitHub App ID}"
INSTALLATION_ID="${GITHUB_APP_INSTALLATION_ID:?Missing Installation ID}"
PRIVATE_KEY="${GITHUB_APP_PRIVATE_KEY:?Missing private key path}"

kubectl --context "$CONTEXT" -n argocd create secret generic github-app-repo \
  --from-literal=type=git \
  --from-literal=url="$REPO_URL" \
  --from-literal=githubAppID="$APP_ID" \
  --from-literal=githubAppInstallationID="$INSTALLATION_ID" \
  --from-file=githubAppPrivateKey="$PRIVATE_KEY" \
  --dry-run=client -o yaml |
kubectl label --local -f - \
  argocd.argoproj.io/secret-type=repository -o yaml |
kubectl --context "$CONTEXT" -n argocd apply --server-side -f -