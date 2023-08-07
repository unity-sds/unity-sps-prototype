variable "kubeconfig_filepath" {
  description = "The file path of the kubeconfig file"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace to create resources in"
  type        = string
}

variable "airflow_home" {
  description = "The Airflow home directory"
  type        = string
}

variable "storage_class_name" {
  description = "The Kuberenetes storage class."
  type        = string
  default     = "gp2"
}

variable "cwl_tmp_folder" {
  description = "The CWL temp directory"
  type        = string
}

variable "cwl_inputs_folder" {
  description = "The CWL inputs directory"
  type        = string
}

variable "cwl_outputs_folder" {
  description = "The CWL outputs directory"
  type        = string
}

variable "cwl_pickle_folder" {
  description = "The CWL pickle directory"
  type        = string
}

variable "process_report_url" {
  description = "The process report URL for Airflow"
  type        = string
}

variable "mysql_user" {
  description = "The MySQL user"
  type        = string
}

variable "mysql_password" {
  description = "The MySQL password"
  type        = string
}

variable "mysql_database" {
  type = string
}

variable "mysql_data_folder" {
  type = string
}

variable "mysql_root_password" {
  description = "The MySQL root password"
  type        = string
}

variable "service_type" {
  description = "value"
  type        = string
  default     = "LoadBalancer"
}

variable "service_port_map" {
  description = "value"
  type        = map(number)
  default = {
    "mysql_service"                 = 3306
    "airflow_cwl_webserver_service" = 8080
    "airflow_cwl_apiserver_service" = 8081
  }
}

variable "elb_subnets" {
  description = "value"
  type        = string
}

variable "docker_images" {
  description = "Docker images for the Unity SPS containers"
  type        = map(string)
  default = {
    dind        = "docker:23.0.3-dind"
    mysql       = "biarms/mysql:5.7"
    airflow_cwl = "ghcr.io/unity-sds/unity-sps-prototype/sps-cwl-airflow:dev"
  }
}
