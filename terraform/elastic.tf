/*
A Release is an instance of a chart running in a Kubernetes cluster.
A Chart is a Helm package. It contains all of the resource definitions
necessary to run an application, tool, or service inside of a Kubernetes cluster.
*/
resource "helm_release" "mozart-es" {
  name       = "mozart-es"
  namespace  = kubernetes_namespace.unity-sps.metadata.0.name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 150
  values = [
    file("${path.module}/../hysds/mozart/elasticsearch/values-override.yml")
  ]
  depends_on = [kubernetes_namespace.unity-sps]
}

resource "helm_release" "grq2-es" {
  name       = "grq2-es"
  namespace  = kubernetes_namespace.unity-sps.metadata.0.name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 150
  values = [
    file("${path.module}/../hysds/grq/elasticsearch/values-override.yml")
  ]
  depends_on = [kubernetes_namespace.unity-sps]
}
