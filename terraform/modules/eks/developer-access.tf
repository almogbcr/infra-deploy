data "aws_caller_identity" "developer_caller" {

}

data "aws_iam_session_context" "developer_caller" {
  arn = data.aws_caller_identity.developer_caller.arn
}

resource "aws_iam_role" "developer" {
  name = "${var.env}-eks-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        AWS = data.aws_iam_session_context.developer_caller.issuer_arn
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_eks_access_entry" "developer" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = aws_iam_role.developer.arn
  kubernetes_groups = ["developers"]
  type              = "STANDARD"
}

resource "aws_iam_role_policy" "developer" {
  name = "describe-eks-cluster"
  role = aws_iam_role.developer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "eks:DescribeCluster"
      Resource = aws_eks_cluster.main.arn
    }]
  })
}