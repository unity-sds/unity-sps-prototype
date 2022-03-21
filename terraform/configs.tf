resource "kubernetes_config_map" "mozart-settings" {
  metadata {
    name = "mozart-settings"
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../hysds/mozart/rest_api/settings.cfg")}"
  }
}

resource "kubernetes_config_map" "grq2-settings" {
  metadata {
    name = "grq2-settings"
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../hysds/grq/rest_api/settings.cfg")}"
  }
}

resource "kubernetes_config_map" "celeryconfig" {
  metadata {
    name = "celeryconfig"
  }
  data = {
    "celeryconfig.py" = "${file("${path.module}/../hysds/configs/celeryconfig.py")}"
  }
}

resource "kubernetes_config_map" "netrc" {
  metadata {
    name = "netrc"
  }
  data = {
    ".netrc" = "${file("${path.module}/../hysds/configs/.netrc")}"
  }
}

resource "kubernetes_config_map" "logstash-configs" {
  metadata {
    name = "logstash-configs"
  }
  data = {
    "job-status"    = "${file("${path.module}/../hysds/mozart/logstash/job_status.template.json")}"
    "event-status"  = "${file("${path.module}/../hysds/mozart/logstash/event_status.template.json")}"
    "worker-status" = "${file("${path.module}/../hysds/mozart/logstash/worker_status.template.json")}"
    "task-status"   = "${file("${path.module}/../hysds/mozart/logstash/task_status.template.json")}"
    "logstash-conf" = "${file("${path.module}/../hysds/mozart/logstash/logstash.conf")}"
    "logstash-yml"  = "${file("${path.module}/../hysds/mozart/logstash/logstash.yml")}"
  }
}

resource "kubernetes_config_map" "supervisord-orchestrator" {
  metadata {
    name = "supervisord-orchestrator"
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../hysds/orchestrator/supervisord.conf")}"
  }
}

resource "kubernetes_config_map" "datasets" {
  metadata {
    name = "datasets"
  }
  data = {
    "datasets.json" = "${file("${path.module}/../hysds/configs/datasets.json")}"
  }
}

resource "kubernetes_config_map" "supervisord-job-worker" {
  metadata {
    name = "supervisord-job-worker"
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../hysds/factotum/supervisord.conf")}"
  }
}


resource "kubernetes_config_map" "supervisord-user-rules" {
  metadata {
    name = "supervisord-user-rules"
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../hysds/user_rules/supervisord.conf")}"
  }
}

# note: these are fake AWS credentials for access to MINIO S3 buckets
resource "kubernetes_config_map" "aws-credentials" {
  metadata {
    name = "aws-credentials"
  }
  data = {
    "aws-credentials" = "${file("${path.module}/../hysds/configs/aws-credentials")}"
  }
}

