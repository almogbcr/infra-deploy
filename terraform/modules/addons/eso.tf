resource "helm_release" "extsec" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.12.0"
  namespace        = "external-secrets"
  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true

      serviceAccount = {
        create = true
        name   = "external-secrets"
      }
    })
  ]

  wait    = true
  timeout = 600
}