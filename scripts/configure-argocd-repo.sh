#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${1:?Usage: $0 <kube-context>}"

REPO_URL="https://github.com/almogbcr/infra-deploy.git"
APP_ID="5948959"
INSTALLATION_ID="186409891"
PRIVATE_KEY="$HOME/.ssh/github-app.pem"

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