# Data source to get existing EKS cluster information
data "aws_eks_cluster" "sps-cluster" {
  name = var.eks_cluster_name
}


# Data source to get existing VPC information
data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
}

# Data source to get existing subnets
data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
}
