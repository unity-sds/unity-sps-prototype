variable "filename" {
    type = string
    default = "sps_airflow.conf"
}

variable "airflow_domain_and_port" {
    type = string
    default = "localhost:8080"
}

variable "region" {
    type = string
    default = "us-west-2"
}