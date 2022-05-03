resource "kubernetes_config_map" "mozart-settings" {
  metadata {
    name      = "mozart-settings"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../../hysds/mozart/rest_api/settings.cfg")}"
  }
}

resource "kubernetes_config_map" "grq2-settings" {
  metadata {
    name      = "grq2-settings"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../../hysds/grq/rest_api/settings.cfg")}"
  }
}

resource "kubernetes_config_map" "celeryconfig" {
  metadata {
    name      = "celeryconfig"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "celeryconfig.py" = "${file("${path.module}/../../hysds/configs/celeryconfig.py")}"
  }
}

resource "kubernetes_config_map" "netrc" {
  metadata {
    name      = "netrc"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    ".netrc" = "${file("${path.module}/../../hysds/configs/.netrc")}"
  }
}

resource "kubernetes_config_map" "logstash-configs" {
  metadata {
    name      = "logstash-configs"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "job-status"    = "${file("${path.module}/../../hysds/mozart/logstash/job_status.template.json")}"
    "event-status"  = "${file("${path.module}/../../hysds/mozart/logstash/event_status.template.json")}"
    "worker-status" = "${file("${path.module}/../../hysds/mozart/logstash/worker_status.template.json")}"
    "task-status"   = "${file("${path.module}/../../hysds/mozart/logstash/task_status.template.json")}"
    "logstash-conf" = "${file("${path.module}/../../hysds/mozart/logstash/logstash.conf")}"
    "logstash-yml"  = "${file("${path.module}/../../hysds/mozart/logstash/logstash.yml")}"
  }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LOG STASH ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
# resource "kubernetes_config_map" "logstash-job-status" {
#   metadata {
#     name      = "logstash-job-status"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "job_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/job_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-event-status" {
#   metadata {
#     name      = "logstash-event-status"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "event_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/event_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-worker-status" {
#   metadata {
#     name      = "logstash-worker-status"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "worker_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/worker_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-task-status" {
#   metadata {
#     name      = "logstash-task-status"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "task_status.template.json" = "${file("${path.module}/../../hysds/mozart/logstash/task_status.template.json")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-conf" {
#   metadata {
#     name      = "logstash-conf"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "logstash.conf" = "${file("${path.module}/../../hysds/mozart/logstash/logstash.conf")}"
#   }
# }

# resource "kubernetes_config_map" "logstash-yml" {
#   metadata {
#     name      = "logstash-yml"
#     namespace = kubernetes_namespace.unity-sps.metadata.0.name
#   }
#   data = {
#     "logstash.yml" = "${file("${path.module}/../../hysds/mozart/logstash/logstash.yml")}"
#   }
# }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


resource "kubernetes_config_map" "supervisord-orchestrator" {
  metadata {
    name      = "supervisord-orchestrator"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/orchestrator/supervisord.conf")}"
  }
}

resource "kubernetes_config_map" "datasets" {
  metadata {
    name      = "datasets"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  # TODO - Using this template file is temporary. A more sophisticated method for generating
  # custom config files will be added in the future. This could take the form of a Terraform
  # resource that generates all the custom config files.
  data = {
    "datasets.json" = "${file("${path.module}/../../hysds/configs/datasets.template.json")}"
  }
}

resource "kubernetes_config_map" "supervisord-job-worker" {
  metadata {
    name      = "supervisord-job-worker"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/factotum/supervisord.conf")}"
  }
}

resource "kubernetes_config_map" "supervisord-verdi" {
  metadata {
    name      = "supervisord-verdi"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
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
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/user_rules/supervisord.conf")}"
  }
}

# note: these are fake AWS credentials for access to MINIO S3 buckets
resource "kubernetes_config_map" "aws-credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "aws-credentials" = "${file("${path.module}/../../hysds/configs/aws-credentials")}"
  }
}
