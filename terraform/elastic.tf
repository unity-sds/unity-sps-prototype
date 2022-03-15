resource "helm_release" "mozart-es" {

  name       = "mozart-es"
  repository = "https://helm.elastic.co"
  version    = "7.9.3"
  wait       = true
  timeout    = 150
  chart      = "elasticsearch"

  values = [
    file("${path.module}/../hysds/mozart/elasticsearch/values-override.yml")
  ]


}

