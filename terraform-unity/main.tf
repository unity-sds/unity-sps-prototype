module "unity-sps-airflow" {
  source              = "./modules/terraform-unity-sps-airflow"
  venue               = var.venue
  counter             = var.counter
  release             = var.release
  eks_cluster_name    = var.eks_cluster_name
  kubeconfig_filepath = var.kubeconfig_filepath
  docker_images       = var.docker_images
  elb_subnets         = var.elb_subnets
}
