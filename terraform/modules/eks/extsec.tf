resource "aws_iam_role" "extsec" {
  name = "${var.env}-extsec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "extsec" {
  name = "${var.env}-extsec-policy"
  role = aws_iam_role.extsec.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        for secret in aws_secretsmanager_secret.app : secret.arn
      ]
    }]
  })
}

resource "aws_eks_pod_identity_association" "extsec" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.extsec.arn

  depends_on = [
    aws_iam_role_policy.extsec
  ]
}