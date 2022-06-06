variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "container_registry" {
  type = object({
    server   = string
    username = string
    password = string
  })
}

variable "docker_images" {
  type = map(string)
  default = {
    hysds_core     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
    hysds_ui       = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1"
    hysds_mozart   = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
    hysds_grq2     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1"
    hysds_verdi    = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1"
    hysds_factotum = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1"
    ades_wpst_api  = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1"
    logstash       = "docker.elastic.co/logstash/logstash:7.10.2"
    minio          = "minio/minio:RELEASE.2022-03-17T06-34-49Z"
    mc             = "minio/mc:RELEASE.2022-03-13T22-34-00Z"
    rabbitmq       = "rabbitmq:3-management"
    busybox        = "k8s.gcr.io/busybox"
    redis          = "redis:latest"
  }
}

variable "mozart_es" {
  type = object({
    cluster_name  = string
    anti_affinity = string
    es_java_opts  = string
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })
    volume_claim_template = object({
      access_modes       = list(string)
      storage_class_name = string
      resources = object({
        requests = object({
          storage = string
        })
      })
    })
    master_service              = string
    cluster_health_check_params = string
    replicas                    = number
    http_port                   = number
    transport_port              = number
  })
  default = {
    cluster_name  = "mozart-es"
    anti_affinity = "soft"
    es_java_opts  = "-Xmx512m -Xms512m"
    resources = {
      requests = {
        cpu    = "1000m"
        memory = "2Gi"
      }
      limits = {
        cpu    = "1000m"
        memory = "2Gi"
      }
    }
    volume_claim_template = {
      access_modes       = ["ReadWriteOnce"]
      storage_class_name = "microk8s-hostpath"
      resources = {
        requests = {
          storage = "5Gi"
        }
      }
    }
    master_service              = "mozart-es"
    cluster_health_check_params = "wait_for_status=yellow&timeout=1s"
    replicas                    = 1
    http_port                   = 9200
    transport_port              = 9300
  }
}

variable "grq2_es" {
  type = object({
    cluster_name  = string
    anti_affinity = string
    es_java_opts  = string
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })
    volume_claim_template = object({
      access_modes       = list(string)
      storage_class_name = string
      resources = object({
        requests = object({
          storage = string
        })
      })
    })
    master_service              = string
    cluster_health_check_params = string
    replicas                    = number
    http_port                   = number
    transport_port              = number
  })
  default = {
    cluster_name  = "grq-es"
    anti_affinity = "soft"
    es_java_opts  = "-Xmx512m -Xms512m"
    resources = {
      requests = {
        cpu    = "1000m"
        memory = "2Gi"
      }
      limits = {
        cpu    = "1000m"
        memory = "2Gi"
      }
    }
    volume_claim_template = {
      access_modes       = ["ReadWriteOnce"]
      storage_class_name = "microk8s-hostpath"
      resources = {
        requests = {
          storage = "5Gi"
        }
      }
    }
    master_service              = "grq-es"
    cluster_health_check_params = "wait_for_status=yellow&timeout=1s"
    replicas                    = 1
    http_port                   = 9201
    transport_port              = 9301
  }
}

variable "service_type" {
  type    = string
  default = "NodePort"
}

variable "node_port_map" {
  type = map(number)
  default = {
    "mozart_service"                    = 30001
    "grq2_service"                      = 30002
    "rabbitmq_mgmt_service_cluster_rpc" = 30003
    "rabbitmq_service_epmd"             = 30004
    "rabbitmq_service_listener"         = 30005
    "rabbitmq_service_cluster_rpc"      = 30006
    "minio_service_api"                 = 30007
    "minio_service_interface"           = 30008
    "hysds_ui_service"                  = 30009
    "redis_service"                     = 30010
    "ades_wpst_api_service"             = 30011
    "grq2_es"                           = 30012
    "mozart_es"                         = 30013
  }
}

variable "datasets_filename" {
  type    = string
  default = "datasets.template.json"
}
