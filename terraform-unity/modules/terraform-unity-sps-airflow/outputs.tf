# output "airflow_webserver_url" {
#   description = "The URL of the Airflow webserver service"
#   value       = "http://${data.kubernetes_service.airflow_webserver.status[0].load_balancer[0].ingress[0].hostname}:8080"
# }
