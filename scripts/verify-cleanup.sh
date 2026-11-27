#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="eu-north-1"
export AWS_PAGER=""

aws sts get-caller-identity

echo "===== AWS CLEANUP CHECK ====="

FAILED=0

check() {
    local NAME="$1"
    shift
    local COUNT

    COUNT=$(aws "$@" --output json)

    if [[ "$COUNT" == "0" ]]; then
        echo "[OK] $NAME: $COUNT"
    else
        echo "[WARNING] $NAME: $COUNT"
        FAILED=1
    fi
}

check "EKS Clusters" eks list-clusters \
  --query 'length(clusters)'

check "EC2 Instances" ec2 describe-instances \
  --filters Name=instance-state-name,Values=pending,running,stopping,stopped,shutting-down \
  --query 'length(Reservations[].Instances[])'

check "Auto Scaling Groups" autoscaling describe-auto-scaling-groups \
  --query 'length(AutoScalingGroups)'

check "Load Balancers" elbv2 describe-load-balancers \
  --query 'length(LoadBalancers)'

check "Classic Load Balancers" elb describe-load-balancers \
  --query 'length(LoadBalancerDescriptions)'

check "NAT Gateways" ec2 describe-nat-gateways \
  --query "length(NatGateways[?State!='deleted'])"

check "Elastic IPs" ec2 describe-addresses \
  --query 'length(Addresses)'

check "EBS Volumes" ec2 describe-volumes \
  --query 'length(Volumes)'

check "EBS Snapshots" ec2 describe-snapshots --owner-ids self \
  --query 'length(Snapshots)'

check "Custom VPCs" ec2 describe-vpcs \
  --query 'length(Vpcs[?IsDefault==`false`])'

check "VPC Endpoints" ec2 describe-vpc-endpoints \
  --query 'length(VpcEndpoints)'

check "Active Secrets" secretsmanager list-secrets \
  --query 'length(SecretList)'

check "CloudWatch Log Groups" logs describe-log-groups \
  --query 'length(logGroups)'

check "Project IAM Roles" iam list-roles \
  --query "length(Roles[?starts_with(RoleName,'dev-') || starts_with(RoleName,'prod-')])"

check "Project IAM Policies" iam list-policies --scope Local \
  --query "length(Policies[?starts_with(PolicyName,'dev-') || starts_with(PolicyName,'prod-')])"

echo "===== SECRETS PENDING DELETION ====="

aws secretsmanager list-secrets --include-planned-deletion \
  --query 'SecretList[?DeletedDate!=`null`].[Name,DeletedDate]' \
  --output table

echo "===== SUMMARY ====="

if [[ "$FAILED" == "0" ]]; then
    echo "No remaining resources detected by the cleanup checks."
else
    echo "WARNING: Resources still exist. Review the results."
fi

exit "$FAILED"