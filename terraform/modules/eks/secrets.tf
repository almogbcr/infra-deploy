resource "aws_secretsmanager_secret" "app" {
  for_each = var.secret_names

  name = each.value

  tags = {
    Env = var.env
  }
}