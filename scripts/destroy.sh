#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export AWS_REGION="eu-north-1"
export AWS_PAGER=""
PUBLIC_IP=$(curl -fsS https://checkip.amazonaws.com)
export EKS_API_CIDR="$PUBLIC_IP/32"

aws sts get-caller-identity

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export TF_STATE_BUCKET="infra-deploy-state-${ACCOUNT_ID}-${AWS_REGION}"

read -rp "Type DESTROY to delete both environments: " CONFIRM
[[ "$CONFIRM" == "DESTROY" ]] || exit 1

# Remove Argo CD applications
for ENV in dev prod; do
    CONTEXT="$ENV-eks"

    aws eks update-kubeconfig --name "$CONTEXT" --alias "$CONTEXT"

    kubectl --context "$CONTEXT" delete \
      -f "argocd/$ENV-cluster/root.yaml" \
      --ignore-not-found --timeout=600s

    kubectl --context "$CONTEXT" delete \
      -f "argocd/$ENV-cluster/apps/" \
      --ignore-not-found --timeout=600s
done

# Remove application namespaces
kubectl --context dev-eks delete namespace dev staging \
  --ignore-not-found --timeout=600s

kubectl --context prod-eks delete namespace production \
  --ignore-not-found --timeout=600s

# Verify that application load balancers are removed
for ENV in dev prod; do
    VPC=$(aws eks describe-cluster --name "$ENV-eks" \
      --query 'cluster.resourcesVpcConfig.vpcId' --output text)

    COUNT=$(aws elbv2 describe-load-balancers \
      --query "length(LoadBalancers[?VpcId=='$VPC'])" --output json)

    if [[ "$COUNT" != "0" ]]; then
        echo "Load balancers still exist in $VPC"
        exit 1
    fi
done

# Destroy infrastructure
cd terragrunt
terragrunt run --all --parallelism 1 -- destroy

echo "Infrastructure destroy completed"