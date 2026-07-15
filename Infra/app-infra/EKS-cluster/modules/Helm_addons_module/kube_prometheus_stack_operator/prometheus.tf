resource "helm_release" "helm_kube_prometheus_stack_operator" {
  name             = "prometheus-operator"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "58.2.2"
  create_namespace = true

  wait    = true
  timeout = 600

  # This is the -f values.yaml equivalent
  values = [
    file("${path.module}/values.yml")   # put values.yaml next to this .tf file
  ]

  # You can still override specific values on top of the file
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password   # don't hardcode passwords
  }
}
