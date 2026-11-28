#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Environment configuration
export AWS_REGION="eu-north-1"
export AWS_PAGER=""
PUBLIC_IP=$(curl -fsS https://checkip.amazonaws.com)
export EKS_API_CIDR="$PUBLIC_IP/32"

# Pre-flight checks
aws sts get-caller-identity

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export TF_STATE_BUCKET="infra-deploy-state-${ACCOUNT_ID}-${AWS_REGION}"

read -rp "Type DEPLOY to create both environments: " CONFIRM
[[ "$CONFIRM" == "DEPLOY" ]] || exit 1

# Check for secrets pending deletion
for ENV in dev staging production; do
    SECRET="$ENV/flask/api-key"

    if RESULT=$(aws secretsmanager describe-secret \
        --secret-id "$SECRET" \
        --query 'DeletedDate' --output text 2>&1); then

        if [[ "$RESULT" != "None" ]]; then
            echo "ERROR: $SECRET is pending deletion"
            exit 1
        fi

    elif [[ "$RESULT" != *ResourceNotFoundException* ]]; then
        echo "$RESULT"
        exit 1
    fi
done

# Initialize remote state backend
(cd terragrunt/dev/network && terragrunt backend bootstrap)

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

# Wait for a child Application to exist, synchronize and become healthy.
wait_for_application() {
    local CONTEXT="$1"
    local APPLICATION="$2"
    local DEADLINE=$((SECONDS + 900))
    local STATUS

    while (( SECONDS < DEADLINE )); do
        STATUS=$(kubectl --context "$CONTEXT" -n argocd get application "$APPLICATION" \
          --ignore-not-found --request-timeout=30s \
          -o jsonpath='{.status.sync.status} {.status.health.status}')

        if [[ "$STATUS" == "Synced Healthy" ]]; then
            echo "$APPLICATION is Synced and Healthy."
            return 0
        fi

        echo "Waiting for $APPLICATION: ${STATUS:-not created yet}"
        sleep 10
    done

    echo "ERROR: Timed out waiting for $APPLICATION in $CONTEXT." >&2
    kubectl --context "$CONTEXT" -n argocd get applications --request-timeout=30s
    return 1
}

# Configure Argo CD and deploy applications
for ENV in dev prod; do
    aws eks update-kubeconfig --name "$ENV-eks" --alias "$ENV-eks"

    kubectl --context "$ENV-eks" apply \
      -f "argocd/$ENV-cluster/root.yaml"

    if [[ "$ENV" == "dev" ]]; then
        wait_for_application "$ENV-eks" webapp-dev
        wait_for_application "$ENV-eks" webapp-staging
    else
        wait_for_application "$ENV-eks" webapp-production
    fi

    kubectl --context "$ENV-eks" get applications -n argocd
done

echo "Deployment completed: all three Applications are Synced and Healthy."
