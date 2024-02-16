variable "cluster_name" {
  type    = string
  default = "sps-processing-cluster"
}

variable "tags" {
  type    = map(string)
  default = {}
}