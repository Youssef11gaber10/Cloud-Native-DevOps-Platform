


resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}
resource "helm_release" "elasticsearch" {
  name             = "elasticsearch"
  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  namespace        = "logging"
  version          = "8.5.1"
  create_namespace = true

  values = [file("${path.module}/values/elasticsearch_values.yml")]

  # Elasticsearch takes long to become healthy
  wait    = true
  timeout = 600

  depends_on = [kubernetes_namespace.logging]
}


resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"
  version    = "8.5.1"

  values = [file("${path.module}/values/kibana_values.yml")]

  wait    = true
  timeout = 300

  # Kibana needs ES credentials secret which ES creates automatically
  depends_on = [helm_release.elasticsearch]
}


resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  namespace  = "logging"
  version    = "8.5.1"

  values = [file("${path.module}/values/logstash_values.yml")]

  wait    = true
  timeout = 300

  # Logstash reads ES credentials from elasticsearch-master-credentials secret
  depends_on = [helm_release.elasticsearch]
}

resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  namespace  = "logging"
  version    = "8.5.1"

  values = [file("${path.module}/values/filebeat_values.yml")]

  wait    = true
  timeout = 300

  # Filebeat ships to logstash-logstash:5044 — Logstash must exist first
  depends_on = [helm_release.logstash]
}