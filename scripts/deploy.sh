#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Environment configuration
export AWS_REGION="eu-north-1"
export AWS_PAGER=""
PUBLIC_IP=$(curl -fsS https://checkip.amazonaws.com)
export EKS_API_CIDR="$PUBLIC_IP/32"

source "$HOME/.config/infra-deploy/argocd.env"
test -r "$GITHUB_APP_PRIVATE_KEY"

# Pre-flight checks
aws sts get-caller-identity
aws secretsmanager list-secrets --include-planned-deletion \
  --query 'SecretList[].[Name,DeletedDate]' --output table

read -rp "No project secrets pending deletion? Type DEPLOY: " CONFIRM
[[ "$CONFIRM" == "DEPLOY" ]] || exit 1

# Deploy infrastructure
(cd terragrunt && terragrunt run --all apply)

# Initialize missing demo secrets
for ENV in dev staging production; do
    SECRET="$ENV/flask/api-key"
    CURRENT=$(aws secretsmanager list-secret-version-ids \
      --secret-id "$SECRET" \
      --query "length(Versions[?contains(VersionStages, 'AWSCURRENT')])" \
      --output json)

    if [[ "$CURRENT" == "0" ]]; then
        aws secretsmanager put-secret-value \
          --secret-id "$SECRET" --secret-string "demo-$ENV-key"
    fi
done

# Configure Argo CD and deploy applications
for ENV in dev prod; do
    aws eks update-kubeconfig --name "$ENV-eks" --alias "$ENV-eks"

    ./scripts/configure-argocd-repo.sh "$ENV-eks"

    kubectl --context "$ENV-eks" apply \
      -f "argocd/$ENV-cluster/root.yaml"

    kubectl --context "$ENV-eks" get applications -n argocd
done