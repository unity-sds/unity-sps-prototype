# resource "null_resource" "build_container" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       cd ${path.module}/../../hysds/
#       source ~/.virtualenvs/hysds/bin/activate
#       python build_container.py -e remote -i hello_world:develop -f pge/hello_world \
#       --mozart-rest-ip ${kubernetes_service.mozart-service.status[0].load_balancer[0].ingress[0].hostname} \
#       --grq-rest-ip ${kubernetes_service.grq2-service.status[0].load_balancer[0].ingress[0].hostname}
#     EOT
#   }
#   depends_on = [kubernetes_job.mc]
# }
