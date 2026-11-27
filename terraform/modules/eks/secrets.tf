resource "aws_secretsmanager_secret" "app" {
  for_each = var.secret_names
  recovery_window_in_days = 0
  name = each.value

  tags = {
    Env = var.env
  }
}