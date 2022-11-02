data "template_file" "mozart-settings" {
  template = "${file("${path.module}/../../hysds/mozart/rest_api/settings.cfg")}"
  vars = {
    rabbitmq_admin_port = var.service_port_map.rabbitmq_mgmt_service_cluster_rpc
    mozart_service_port = var.service_port_map.mozart_service
    mozart_es_port      = var.service_port_map.mozart_es
  }
}

resource "kubernetes_config_map" "mozart-settings" {
  metadata {
    name      = "mozart-settings"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "settings.cfg" = "${chomp(data.template_file.mozart-settings.rendered)}"
  }
}

data "template_file" "grq2-settings" {
  template = "${file("${path.module}/../../hysds/grq/rest_api/settings.cfg")}"
  vars = {
    mozart_es_port     = var.service_port_map.mozart_es
    redis_service_port = var.service_port_map.redis_service
    grq2_es_port       = var.service_port_map.grq2_es
  }
}

resource "kubernetes_config_map" "grq2-settings" {
  metadata {
    name      = "grq2-settings"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "settings.cfg" = "${chomp(data.template_file.grq2-settings.rendered)}"
  }
}

data "template_file" "celeryconfig" {
  template = "${file("${path.module}/../../hysds/configs/${var.celeryconfig_filename}")}"
  vars = {
    rabbitmq_service_port = var.service_port_map.rabbitmq_service_listener
    redis_service_port    = var.service_port_map.redis_service
    mozart_service_port   = var.service_port_map.mozart_service
    mozart_es_port        = var.service_port_map.mozart_es
    grq2_service_port     = var.service_port_map.grq2_service
    grq2_es_port          = var.service_port_map.grq2_es
  }
}

resource "kubernetes_config_map" "celeryconfig" {
  metadata {
    name      = "celeryconfig"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "celeryconfig.py" = "${chomp(data.template_file.celeryconfig.rendered)}"
  }
}

resource "kubernetes_config_map" "netrc" {
  metadata {
    name      = "netrc"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    ".netrc" = "${file("${path.module}/../../hysds/configs/.netrc")}"
  }
}

data "template_file" "logstash-conf" {
  template = "${file("${path.module}/../../hysds/mozart/logstash/logstash.conf")}"
  vars = {
    mozart_es_port = var.service_port_map.mozart_es
  }
}

data "template_file" "logstash-yml" {
  template = "${file("${path.module}/../../hysds/mozart/logstash/logstash.yml")}"
  vars = {
    mozart_es_port = var.service_port_map.mozart_es
  }
}

resource "kubernetes_config_map" "logstash-configs" {
  metadata {
    name      = "logstash-configs"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "job-status"    = "${file("${path.module}/../../hysds/mozart/logstash/job_status.template.json")}"
    "event-status"  = "${file("${path.module}/../../hysds/mozart/logstash/event_status.template.json")}"
    "worker-status" = "${file("${path.module}/../../hysds/mozart/logstash/worker_status.template.json")}"
    "task-status"   = "${file("${path.module}/../../hysds/mozart/logstash/task_status.template.json")}"
    "logstash-conf" = "${chomp(data.template_file.logstash-conf.rendered)}"
    "logstash-yml"  = "${chomp(data.template_file.logstash-yml.rendered)}"
  }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LOG STASH ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
# resource "kubernetes_config_map" "logstash-job-status" {
#   metadata {
#     name      = "logstash-job-status"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "job_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/job_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-event-status" {
#   metadata {
#     name      = "logstash-event-status"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "event_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/event_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-worker-status" {
#   metadata {
#     name      = "logstash-worker-status"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "worker_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/worker_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-task-status" {
#   metadata {
#     name      = "logstash-task-status"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "task_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/task_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-conf" {
#   metadata {
#     name      = "logstash-conf"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "logstash.conf" = "${file("${path.module}/../../hysds/mozart/logstash/logstash.conf")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-yml" {
#   metadata {
#     name      = "logstash-yml"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#   }
#   data = {
#     "logstash.yml" = "${file("${path.module}/../../hysds/mozart/logstash/logstash.yml")}"
#   }
# }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


resource "kubernetes_config_map" "supervisord-orchestrator" {
  metadata {
    name      = "supervisord-orchestrator"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/orchestrator/supervisord.conf")}"
  }
}

data "template_file" "datasets" {
  template = "${file("${path.module}/../../hysds/configs/${var.datasets_filename}")}"
  vars = {
    minio_service_api_port       = var.service_port_map.minio_service_api
    minio_service_interface_port = var.service_port_map.minio_service_interface
  }
}

resource "kubernetes_config_map" "datasets" {
  metadata {
    name      = "datasets"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  # TODO - Using this template file is temporary. A more sophisticated method for generating
  # custom config files will be added in the future. This could take the form of a Terraform
  # resource that generates all the custom config files.
  data = {
    "datasets.json" = "${chomp(data.template_file.datasets.rendered)}"
  }
}

resource "kubernetes_config_map" "supervisord-job-worker" {
  metadata {
    name      = "supervisord-job-worker"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/factotum/supervisord.conf")}"
  }
}

resource "kubernetes_config_map" "supervisord-verdi" {
  metadata {
    name      = "supervisord-verdi"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  # TODO - Using this template file is temporary. A more sophisticated method for generating
  # custom config files will be added in the future. This could take the form of a Terraform
  # resource that generates all the custom config files.
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/verdi/supervisord.template.conf")}"
  }
}

resource "kubernetes_config_map" "supervisord-user-rules" {
  metadata {
    name      = "supervisord-user-rules"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/user_rules/supervisord.conf")}"
  }
}

# note: these are fake AWS credentials for access to MINIO S3 buckets
resource "kubernetes_config_map" "aws-credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    "aws-credentials" = "${file("${path.module}/../../hysds/configs/aws-credentials")}"
  }
}


# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1329
locals {
  cwl_workflows_directory            = "/Users/drewm/Documents/projects/398G/Unity/unity-sps-workflows/sounder_sips"
  cwl_workflow_utils_directory       = "/Users/drewm/Documents/projects/398G/Unity/unity-sps-workflows/sounder_sips/utils"
  sounder_sips_static_data_directory = abspath("${path.module}/../../dev_data/STATIC_DATA/SOUNDER_SIPS")
}

resource "kubernetes_config_map" "cwl-workflows" {
  metadata {
    name      = "cwl-workflows"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    for f in fileset(local.cwl_workflows_directory, "*") :
    f => file(join("/", [local.cwl_workflows_directory, f]))
  }
}

resource "kubernetes_config_map" "cwl-workflow-utils" {
  metadata {
    name      = "cwl-workflow-utils"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    for f in fileset(local.cwl_workflow_utils_directory, "*") :
    f => file(join("/", [local.cwl_workflow_utils_directory, f]))
  }
}

resource "kubernetes_config_map" "sounder-sips-static-data" {
  metadata {
    name      = "sounder-sips-static-data"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  data = {
    for f in fileset(local.sounder_sips_static_data_directory, "*") :
    f => filebase64sha256(join("/", [local.sounder_sips_static_data_directory, f]))
  }
}
