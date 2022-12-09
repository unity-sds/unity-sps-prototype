resource "aws_efs_file_system" "efs" {
  creation_token   = "usps-dev-efs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "sps-dev-efs-fs"
  }
}

data "external" "eks_vpc_id" {
  program = ["sh", "-c", "aws eks describe-cluster --name u-sps-dev-prototype-cluster | jq '.cluster.resourcesVpcConfig | {vpcId: .vpcId}'"]
}

data "external" "eks_sg_id" {
  program = ["sh", "-c", "aws eks describe-cluster --name u-sps-dev-prototype-cluster | jq '.cluster.resourcesVpcConfig | {clusterSecurityGroupId: .clusterSecurityGroupId}'"]
}

# data "external" "eks_subnet_ids" {
#   program = ["sh", "-c", "aws eks describe-cluster --name u-sps-dev-prototype-cluster | jq '.cluster.resourcesVpcConfig | {subnetIds: .subnetIds}'"]
# }

# resource "aws_security_group" "efs_sg" {
#   name        = "sps-dev-efs-sg"
#   description = "Allows inbound EFS traffic from SPS cluster"
#   vpc_id      = data.external.eks_vpc_id.result["vpcId"]

#   ingress {
#     security_groups = [data.external.eks_sg_id.result["clusterSecurityGroupId"]]
#     from_port       = 2049
#     to_port         = 2049
#     protocol        = "tcp"
#   }

#   egress {
#     security_groups = [data.external.eks_sg_id.result["clusterSecurityGroupId"]]
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#   }
# }

resource "aws_efs_mount_target" "efs_mt" {
  file_system_id = aws_efs_file_system.efs.id
  #   subnet_id      = "subnet-00db2965967acb6b1"
  subnet_id = "subnet-092597c48cfec3f04"
  #   security_groups = [aws_security_group.efs_sg.id]
  security_groups = [data.external.eks_sg_id.result["clusterSecurityGroupId"]]
}

resource "kubernetes_persistent_volume" "efs" {
  metadata {
    name = "sps-dev-efs-fs"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "gp2-sps"

    capacity = {
      storage = "10Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      nfs {
        server    = aws_efs_mount_target.efs_mt.ip_address
        path      = "/shared"
        read_only = false
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs" {
  metadata {
    name      = "sps-dev-efs-fs"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.efs.metadata.0.name
  }
}
