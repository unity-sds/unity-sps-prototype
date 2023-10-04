resource "kubernetes_persistent_volume" "mozart-es-pv" {
  metadata {
    name = "mozart-es-pv"
  }

  spec {
    storage_class_name = "gp2"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "5Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      host_path {
        path = "/data/mozart-es"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "grq-es-pv" {
  metadata {
    name = "grq-es-pv"
  }

  spec {
    storage_class_name = "gp2"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "5Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      host_path {
        path = "/data/grq-es"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "jobs-es-pv" {
  metadata {
    name = "jobs-es-pv"
  }

  spec {
    storage_class_name = "gp2"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "5Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      host_path {
        path = "/data/jobs-es"
      }
    }
  }
}

locals {
  mozart_es_values = {
    clusterName = "mozart-es"
    node_selector = {
      "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
    }
    # Permit co-located instances for solitary minikube virtual machines.
    antiAffinity = "soft"
    # Shrink default JVM heap.
    esJavaOpts = "-Xmx512m -Xms512m"
    # Allocate smaller chunks of memory per pod.
    resources = {
      # requests = {
      #   cpu    = "250m"
      #   memory = "50Mi"
      # }
      # limits = {
      #   cpu    = "250m"
      #   memory = "50Mi"
      # }
      # Scaling down resourcse since I'm getting this error:
      # Warning  FailedScheduling  19s (x7 over 5m55s)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
      limits = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
    extraInitContainers = [
      {
        name    = "file-permissions"
        image   = var.docker_images.busybox
        command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/"]
        volumeMounts = [
          {
            mountPath = "/usr/share/elasticsearch/data"
            name      = "mozart-es-master"
          }
        ]
        securityContext = {
          privileged = true
          runAsUser  = 0
        }
      }
    ]
    # Request smaller persistent volumes.
    volumeClaimTemplate = {
      volumeName       = kubernetes_persistent_volume.mozart-es-pv.metadata[0].name
      accessModes      = ["ReadWriteOnce"]
      storageClassName = "gp2"
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
      type = "NodePort"
      port = var.service_port_map.mozart_es
    }
    httpPort      = var.service_port_map.mozart_es
    transportPort = 9300
    esConfig = {
      "elasticsearch.yml" = <<-EOT
      http.cors.enabled : true
      http.cors.allow-origin: "*"
      http.port: ${var.service_port_map.mozart_es}
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
            ES_URL=http://localhost:${var.service_port_map.mozart_es}
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
  grq2_es_values = {
    clusterName = "grq-es"
    node_selector = {
      "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
    }
    # Permit co-located instances for solitary minikube virtual machines.
    antiAffinity = "soft"
    # Shrink default JVM heap.
    esJavaOpts = "-Xmx512m -Xms512m"
    # Allocate smaller chunks of memory per pod.
    resources = {
      # requests = {
      #   cpu    = "250m"
      #   memory = "50Mi"
      # }
      # limits = {
      #   cpu    = "250m"
      #   memory = "50Mi"
      # }
      # Scaling down resourcse since I'm getting this error:
      # Warning  FailedScheduling  19s (x7 over 5m55s)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
      limits = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
    extraInitContainers = [
      {
        name    = "file-permissions"
        image   = var.docker_images.busybox
        command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/"]
        volumeMounts = [
          {
            mountPath = "/usr/share/elasticsearch/data"
            name      = "grq-es-master"
          }
        ]
        securityContext = {
          privileged = true
          runAsUser  = 0
        }
      }
    ]

    # Request smaller persistent volumes.
    volumeClaimTemplate = {
      volumeName       = kubernetes_persistent_volume.grq-es-pv.metadata[0].name
      accessModes      = ["ReadWriteOnce"]
      storageClassName = "gp2"
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
      type = "NodePort"
      port = var.service_port_map.grq2_es
    }
    httpPort      = var.service_port_map.grq2_es
    transportPort = 9301

    esConfig = {
      "elasticsearch.yml" = <<-EOT
        http.cors.enabled : true
        http.cors.allow-origin: "*"
        http.port: ${var.service_port_map.grq2_es}
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
            ES_URL=http://localhost:${var.service_port_map.grq2_es}
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
  jobs_es_values = {
    clusterName = "jobs-es"
    node_selector = {
      "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
    }
    # Permit co-located instances for solitary minikube virtual machines.
    antiAffinity = "soft"
    # Shrink default JVM heap.
    esJavaOpts = "-Xmx512m -Xms512m"
    # Allocate smaller chunks of memory per pod.
    resources = {
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
      limits = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
    extraInitContainers = [
      {
        name    = "file-permissions"
        image   = var.docker_images.busybox
        command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/"]
        volumeMounts = [
          {
            mountPath = "/usr/share/elasticsearch/data"
            name      = "jobs-es-master"
          }
        ]
        securityContext = {
          privileged = true
          runAsUser  = 0
        }
      },
      {
        name    = "remove-files"
        image   = var.docker_images.busybox
        command = ["sh", "-c", "rm -rf /usr/share/elasticsearch/data/*"]
        volumeMounts = [
          {
            mountPath = "/usr/share/elasticsearch/data"
            name      = "jobs-es-master"
          }
        ]
        securityContext = {
          privileged = true
          runAsUser  = 0
        }
      }
    ]
    # Request smaller persistent volumes.
    volumeClaimTemplate = {
      volumeName       = kubernetes_persistent_volume.jobs-es-pv.metadata[0].name
      accessModes      = ["ReadWriteOnce"]
      storageClassName = "gp2"
      resources = {
        requests = {
          storage = "5Gi"
        }
      }
    }
    # elasticsearch:
    masterService = "jobs-es"
    # because we're using 1 node the cluster health will be YELLOW instead of GREEN after data is ingested
    clusterHealthCheckParams = "wait_for_status=yellow&timeout=1s"
    replicas                 = 1
    service = {
      type = var.service_type
      port = var.service_port_map.jobs_es
    }
    httpPort      = var.service_port_map.jobs_es
    transportPort = 9300
    esConfig = {
      "elasticsearch.yml" = <<-EOT
      http.cors.enabled : true
      http.cors.allow-origin: "*"
      http.port: ${var.service_port_map.jobs_es}
      EOT
    }
  }
}

resource "null_resource" "upload_jobs_template" {
  provisioner "local-exec" {
    command = <<-EOT
      set -x
      ES_URL=${data.kubernetes_service.jobs-es.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.jobs_es}
      while [[ "$(curl -s -o /dev/null -w '%%{http_code}\n' $ES_URL)" != "200" ]]; do sleep 1; done
      jobs_es_template='{
        "index_patterns": ["jobs*"],
        "template": {
          "settings": {
            "number_of_shards": 1,
            "number_of_replicas": 1
          },
          "mappings": {
            "dynamic": "true",
            "properties": {
              "id": {
                "type": "keyword"
              },
              "inputs": {
                "enabled": false
              },
              "outputs": {
                "enabled": false
              },
              "status": {
                "type": "keyword"
              },
              "labels": {
                "enabled": false
              }
            }
          }
        }
      }'
      curl -X PUT "$ES_URL/_index_template/jobs_template" -H 'Content-Type: application/json' -d "$jobs_es_template"
    EOT
  }
}

/*
A Release is an instance of a chart running in a Kubernetes cluster.
A Chart is a Helm package. It contains all of the resource definitions
necessary to run an application, tool, or service inside of a Kubernetes cluster.
*/
resource "helm_release" "mozart-es" {
  name       = "mozart-es"
  namespace  = kubernetes_namespace.unity-sps.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 600
  values = [
    yamlencode(local.mozart_es_values),
    yamlencode({
      "service" = {
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-name" = "${var.project}-${var.venue}-${var.service_area}-mozart-ElasticsearchLoadBalancer-${local.counter}"
          "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [for k, v in merge(local.common_tags, {
            "Name"      = "${var.project}-${var.venue}-${var.service_area}-mozart-ElasticsearchLoadBalancer-${local.counter}"
            "Component" = "mozart"
            "Stack"     = "mozart"
          }) : format("%s=%s", k, v)])
          "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
        }
      }
    })
  ]
}

resource "helm_release" "grq2-es" {
  name       = "grq2-es"
  namespace  = kubernetes_namespace.unity-sps.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 600
  values = [
    yamlencode(local.grq2_es_values),
    yamlencode({
      "service" = {
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-name" = "${var.project}-${var.venue}-${var.service_area}-grq-ElasticsearchLoadBalancer-${local.counter}"
          "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [for k, v in merge(local.common_tags, {
            "Name"      = "${var.project}-${var.venue}-${var.service_area}-grq-ElasticsearchLoadBalancer-${local.counter}"
            "Component" = "grq"
            "Stack"     = "grq"
          }) : format("%s=%s", k, v)])
          "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
        }
      }
    })
  ]
}

resource "helm_release" "jobs-es" {
  name       = "jobs-es"
  namespace  = kubernetes_namespace.unity-sps.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.9.3"
  wait       = true
  timeout    = 600
  values = [
    yamlencode(local.jobs_es_values),
    yamlencode({
      "service" = {
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-name" = "${var.project}-${var.venue}-${var.service_area}-jobs-ElasticsearchLoadBalancer-${local.counter}"
          "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [for k, v in merge(local.common_tags, {
            "Name"      = "${var.project}-${var.venue}-${var.service_area}-jobs-ElasticsearchLoadBalancer-${local.counter}"
            "Component" = "jobs"
            "Stack"     = "jobs"
          }) : format("%s=%s", k, v)])
          "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
          "service.beta.kubernetes.io/aws-load-balancer-scheme" = var.lb_scheme
          "service.beta.kubernetes.io/aws-load-balancer-internal" = var.legacy_lb_internal
        }
      }
    })
  ]
}
