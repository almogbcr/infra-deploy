resource "aws_iam_policy" "alb" {
  name   = "${var.env}-alb-controller-policy"
  policy = file("${path.module}/alb-iam-policy.json")
}

resource "aws_iam_role" "alb" {
  name = "${var.env}-alb-controller-role"

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

resource "aws_iam_role_policy_attachment" "alb" {
  role       = aws_iam_role.alb.name
  policy_arn = aws_iam_policy.alb.arn
}

resource "aws_eks_pod_identity_association" "alb" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb.arn

  depends_on = [
    aws_iam_role_policy_attachment.alb
  ]
}