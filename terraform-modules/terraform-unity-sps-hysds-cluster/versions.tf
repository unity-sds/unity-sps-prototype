terraform {
  required_version = ">= 1.3.6"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
