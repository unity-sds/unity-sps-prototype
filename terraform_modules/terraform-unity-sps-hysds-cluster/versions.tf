terraform {
  required_version = ">= 1.1.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}
