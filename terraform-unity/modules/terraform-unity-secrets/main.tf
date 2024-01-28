provider "aws" {
  region = var.region
}

locals {
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
