# Deployment and Cleanup Scripts

Run scripts from a machine with AWS credentials, Terraform, Terragrunt,
kubectl and access to the EKS API. The scripts use `eu-north-1` and restrict
EKS API access to the machine's detected public IP.

## Deploy

```bash
bash scripts/deploy.sh
```

After confirmation with `DEPLOY`, the script provisions both clusters and
their add-ons, initializes missing demo application secrets and applies the
Argo CD root Applications.

It waits up to 15 minutes per child Application for both `Synced` and
`Healthy`. A missing Application is retried. API errors and timeouts cause
the script to fail. This checks Argo CD status; it does not replace live
application smoke tests or automatically undo a failed deployment.

## Destroy

```bash
bash scripts/destroy.sh
```

After confirmation with `DESTROY`, the script removes Argo CD Applications
and application namespaces while their controllers are still running.
It then checks every 10 seconds for load balancers in each cluster VPC to
disappear, with a 10-minute timeout per VPC. A timeout or AWS API error stops
the script before Terraform destruction.

Once load balancers are gone, Terragrunt destroys infrastructure in dependency
order. Cleanup verification runs on exit, including after failure. The S3
state bucket is retained. Verification scans many resource types across the
region, so unrelated resources may also be reported.
