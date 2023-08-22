provider "kubernetes" {
  config_path = var.kubeconfig_filepath
  insecure    = true
}

resource "kubernetes_namespace" "unity-sps" {
  metadata {
    name = var.namespace
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filepath
    insecure    = true
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "random_id" "counter" {
  byte_length = 2
}

locals {
  counter = var.counter != "" ? var.counter : random_id.counter.hex
  common_tags = {
    Name        = ""
    Venue       = var.venue
    Proj        = var.project
    ServiceArea = var.service_area
    CapVersion  = var.release
    Component   = ""
    CreatedBy   = var.service_area
    Env         = var.venue
    mission     = var.project
    Stack       = ""
  }
}
