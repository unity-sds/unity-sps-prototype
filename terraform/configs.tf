resource "kubernetes_config_map" "netrc" {
  metadata {
    name = "netrc"
  }
  data = {
    ".netrc" = "${file("${path.module}/../hysds/configs/.netrc")}"
  }
}

resource "kubernetes_config_map" "mozart-settings" {
  metadata {
    name = "mozart-settings"
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../hysds/mozart/rest_api/settings.cfg")}"
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

resource "kubernetes_config_map" "logstash-configs" {
  metadata {
    name = "logstash-configs"
  } 
  data = {
    "job-status" = "${file("${path.module}/../hysds/mozart/logstash/job_status.template.json")}"
    "event-status" = "${file("${path.module}/../hysds/mozart/logstash/event_status.template.json")}"
    "worker-status" = "${file("${path.module}/../hysds/mozart/logstash/worker_status.template.json")}"
    "task-status" = "${file("${path.module}/../hysds/mozart/logstash/task_status.template.json")}"
    "logstash-conf" = "${file("${path.module}/../hysds/mozart/logstash/logstash.conf")}"
    "logstash-yml" = "${file("${path.module}/../hysds/mozart/logstash/logstash.yml")}"
  }
}

