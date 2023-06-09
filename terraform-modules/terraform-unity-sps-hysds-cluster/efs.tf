resource "kubernetes_storage_class" "efs_storage_class" {
  metadata {
    name = "${var.project}-${var.venue}-${var.service_area}-efs-sc"
  }
  storage_provisioner = "kubernetes.io/aws-efs"
  reclaim_policy      = "Delete"
  parameters          = {}
}

data "aws_efs_mount_target" "uads-development-efs-fsmt" {
  count           = var.uads_development_efs_fsmt_id != null ? 1 : 0
  mount_target_id = var.uads_development_efs_fsmt_id
}

resource "aws_security_group_rule" "efs_ingress" {
  for_each                 = length(data.aws_efs_mount_target.uads-development-efs-fsmt) > 0 ? toset(data.aws_efs_mount_target.uads-development-efs-fsmt[0].security_groups) : toset([])
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = each.key
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "efs_egress" {
  for_each                 = length(data.aws_efs_mount_target.uads-development-efs-fsmt) > 0 ? toset(data.aws_efs_mount_target.uads-development-efs-fsmt[0].security_groups) : toset([])
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = each.key
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}

resource "kubernetes_persistent_volume" "uads-development-efs" {
  count = var.uads_development_efs_fsmt_id != null ? 1 : 0
  depends_on = [
    aws_security_group_rule.efs_egress,
    aws_security_group_rule.efs_ingress
  ]
  metadata {
    name = "uads-development-efs"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata[0].name

    capacity = {
      storage = "10Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      nfs {
        server    = data.aws_efs_mount_target.uads-development-efs-fsmt[count.index].ip_address
        path      = "/shared"
        read_only = false
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "uads-development-efs" {
  count = var.uads_development_efs_fsmt_id != null ? 1 : 0
  metadata {
    name      = "uads-development-efs"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]

    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata[0].name

    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.uads-development-efs[count.index].metadata[0].name
  }
}

resource "aws_efs_file_system" "verdi-stage-efs"{
  creation_token = "unity-sps-verdi-stage-efs"
  tags = local.common_tags
}

resource "aws_efs_mount_target" "verdi-stage-efs-mnt-target"{
  file_system_id = aws_efs_file_system.verdi-stage-efs.id
  subnet_id = split(",", var.elb_subnets)[0]
  security_groups = toset([aws_security_group.verdi-efs-sg.id])
}

resource "kubernetes_persistent_volume" "verdi-stage-efs-pv" {
  depends_on = [ aws_security_group_rule.verdi_efs_egress, aws_security_group_rule.verdi_efs_ingress ]
  metadata {
    name = "verdi-stage-efs"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata[0].name

    capacity = {
      storage = "5Ti"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      nfs {
        server = aws_efs_mount_target.verdi-stage-efs-mnt-target.ip_address
        path = "/"
        read_only = false
      }
    }
  }
}

resource "aws_security_group" "verdi-efs-sg" {
  name = "verdi-efs-sg"
  vpc_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  tags = local.common_tags
}

resource "aws_security_group_rule" "verdi_efs_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.verdi-efs-sg.id
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "verdi_efs_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.verdi-efs-sg.id
  source_security_group_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].cluster_security_group_id
}