resource "kubernetes_storage_class" "efs_storage_class" {
  metadata {
    name = "${var.project}-${var.venue}-${var.service_area}-efs-sc"
  }
  storage_provisioner = "kubernetes.io/aws-efs"
  reclaim_policy      = "Delete"
  parameters          = {}
}

resource "aws_efs_file_system" "hysds_efs" {
  creation_token   = "${var.project}-${var.venue}-${var.service_area}-hysds-efs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "${var.project}-${var.venue}-${var.service_area}-hysds-efs"
  }
}

resource "aws_security_group" "hysds_efs_sg" {
  name        = "${var.project}-${var.venue}-${var.service_area}-hysds-efs_sg"
  description = "Allows inbound EFS traffic from SPS cluster"
  vpc_id      = data.aws_vpc.unity_vpc.id

  ingress {
    security_groups = [data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  egress {
    security_groups = [data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
}

resource "aws_efs_mount_target" "hysds_efs_mt" {
  file_system_id = aws_efs_file_system.hysds_efs.id
  # subnet_id       = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
  subnet_id = "subnet-04af313ddac6a1b3b"
  # subnet_id       = "subnet-0ca61daf80bc568d9"
  security_groups = [aws_security_group.hysds_efs_sg.id]
}


data "aws_efs_mount_target" "uads-development-efs-fsmt" {
  mount_target_id = var.uads_development_efs_fsmt_id
}

resource "aws_security_group_rule" "efs_ingress" {
  for_each                 = toset(data.aws_efs_mount_target.uads-development-efs-fsmt.security_groups)
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = each.key
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "efs_egress" {
  for_each                 = toset(data.aws_efs_mount_target.uads-development-efs-fsmt.security_groups)
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = each.key
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}

resource "kubernetes_persistent_volume" "uads-development-efs" {
  depends_on = [
    aws_security_group_rule.efs_egress,
    aws_security_group_rule.efs_ingress
  ]
  metadata {
    name = "uads-development-efs"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata.0.name

    capacity = {
      storage = "10Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      nfs {
        server    = data.aws_efs_mount_target.uads-development-efs-fsmt.ip_address
        path      = "/shared"
        read_only = false
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "uads-development-efs" {
  metadata {
    name      = "uads-development-efs"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]

    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata.0.name

    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.uads-development-efs.metadata.0.name
  }
}
