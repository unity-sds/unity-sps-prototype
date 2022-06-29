locals {
  mozart-es-values = {
    clusterName = "mozart-es"
    # Permit co-located instances for solitary minikube virtual machines.
    antiAffinity = "soft"
    # Shrink default JVM heap.
    esJavaOpts = "-Xmx512m -Xms512m"
    # Allocate smaller chunks of memory per pod.
    resources = {
      requests = {
        cpu    = "250m"
        memory = "50Mi"
      }
      limits = {
        cpu    = "250m"
        memory = "50Mi"
      }
      # Scaling down resourcse since I'm getting this error:
      # Warning  FailedScheduling  19s (x7 over 5m55s)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
      # requests = {
      #   cpu    = "1000m"
      #   memory = "2Gi"
      # }
      # limits = {
      #   cpu    = "1000m"
      #   memory = "2Gi"
      # }
    }
    # Request smaller persistent volumes.
    volumeClaimTemplate = {
      accessModes      = ["ReadWriteOnce"]
      storageClassName = var.mozart_es.volume_claim_template.storage_class_name
      resources = {
        requests = {
          storage = "5Gi"
        }
      }
    }
    # elasticsearch:
    masterService = "mozart-es"
    # because we're using 1 node the cluster health will be YELLOW instead of GREEN after data is ingested
    clusterHealthCheckParams = "wait_for_status=yellow&timeout=1s"
    replicas                 = 1
    service = {
      type     = var.service_type
      nodePort = var.service_type != "NodePort" ? null : var.node_port_map.mozart_es
    }
    httpPort      = 9200
    transportPort = 9300
    esConfig = {
      "elasticsearch.yml" = <<-EOT
      http.cors.enabled : true
      http.cors.allow-origin: "*"
      EOT
    }
    lifecycle = {
      postStart = {
        exec = {
          command = [
            "bash",
            "-c",
            <<-EOT
            #!/bin/bash
            ES_URL=http://localhost:9200
            while [[ "$(curl -s -o /dev/null -w '%%{http_code}\n' $ES_URL)" != "200" ]]; do sleep 1; done
            mozart_es_template=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/es_template.json)
            for idx in "containers" "job_specs" "hysds_io"; do
              template=$(echo $${mozart_es_template} | sed "s/{{ index }}/$${idx}/")
              curl -X PUT "$ES_URL/_template/$${idx}" -H 'Content-Type: application/json' -d "$${template}" >/dev/null
            done

            hysds_io_mozart=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/hysds_ios.mapping)
            curl -X PUT "$ES_URL/_template/hysds_ios-mozart?pretty" -H 'Content-Type: application/json' -d '$${hysds_io_mozart}'

            user_rules_mozart=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/user_rules_job.mapping)
            curl -X PUT "$ES_URL/user_rules-mozart?pretty" -H 'Content-Type: application/json' -d "$${user_rules_mozart}"

            hysds_io_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/hysds_ios.mapping)
            curl -X PUT "$ES_URL/hysds_ios-grq?pretty"  -H 'Content-Type: application/json' -d "$${hysds_io_grq}"

            user_rules_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/user_rules_dataset.mapping)
            curl -X PUT "$ES_URL/user_rules-grq?pretty" -H 'Content-Type: application/json' -d "$${user_rules_grq}"
            EOT
          ]
        }
      }
    }
  }
  grq2-es-values = {
    clusterName = "grq-es"
    # Permit co-located instances for solitary minikube virtual machines.
    antiAffinity = "soft"
    # Shrink default JVM heap.
    esJavaOpts = "-Xmx512m -Xms512m"
    # Allocate smaller chunks of memory per pod.
    resources = {
      requests = {
        cpu    = "250m"
        memory = "50Mi"
      }
      limits = {
        cpu    = "250m"
        memory = "50Mi"
      }
      # Scaling down resourcse since I'm getting this error:
      # Warning  FailedScheduling  19s (x7 over 5m55s)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
      # requests = {
      #   cpu    = "1000m"
      #   memory = "2Gi"
      # }
      # limits = {
      #   cpu    = "1000m"
      #   memory = "2Gi"
      # }
    }
    # Request smaller persistent volumes.
    volumeClaimTemplate = {
      accessModes      = ["ReadWriteOnce"]
      storageClassName = var.grq2_es.volume_claim_template.storage_class_name
      resources = {
        requests = {
          storage = "5Gi"
        }
      }
    }
    # elasticsearch:
    masterService = "grq-es"
    # because we're using 1 node the cluster health will be YELLOW instead of GREEN after data is ingested
    clusterHealthCheckParams = "wait_for_status=yellow&timeout=1s"
    replicas                 = 1
    service = {
      type     = var.service_type
      nodePort = var.service_type != "NodePort" ? null : var.node_port_map.grq2_es
    }
    httpPort      = 9201
    transportPort = 9301

    esConfig = {
      "elasticsearch.yml" = <<-EOT
        http.cors.enabled : true
        http.cors.allow-origin: "*"
        http.port: 9201
        EOT
    }
    lifecycle = {
      postStart = {
        exec = {
          command = [
            "bash",
            "-c",
            <<-EOT
            #!/bin/bash
            ES_URL=http://localhost:9201
            while [[ "$(curl -s -o /dev/null -w '%%{http_code}\n' $ES_URL)" != "200" ]]; do sleep 1; done

            grq_es_template=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/es_template.json)
            template=$(echo $${grq_es_template} | sed 's/{{ prefix }}/grq/;s/{{ alias }}/grq/')
            curl -X PUT "$ES_URL/_template/grq" -H 'Content-Type: application/json' -d "$${template}"

            ingest_pipeline=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/ingest_pipeline.json)
            curl -X PUT "$ES_URL/_ingest/pipeline/dataset_pipeline" -H 'Content-Type: application/json' -d "$${ingest_pipeline}"
            EOT
          ]
        }
      }
    }
  }
}

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
  timeout    = 300
  # TODO move away from values-override.yml
  # values = [
  #   file("${path.module}/../../hysds/mozart/elasticsearch/values-override.yml")
  # ]
  values = [
    yamlencode(local.mozart-es-values)
  ]
  # depends_on = [kubernetes_namespace.unity-sps]
}


resource "helm_release" "grq2-es" {
  name       = "grq2-es"
  namespace  = kubernetes_namespace.unity-sps.metadata.0.name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 300
  # TODO move away from values-override.yml
  # values = [
  #   file("${path.module}/../../hysds/grq/elasticsearch/values-override.yml")
  # ]
  values = [
    yamlencode(local.grq2-es-values)
  ]
  # depends_on = [kubernetes_namespace.unity-sps]
}
