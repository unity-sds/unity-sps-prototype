resource "kubernetes_storage_class" "gp2-sps" {
  metadata {
    name = "gp2-sps"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
  allow_volume_expansion = true
  mount_options          = ["debug"]
}

resource "null_resource" "unset_default" {
  depends_on = [kubernetes_storage_class.gp2-sps]
  provisioner "local-exec" {
    command = "kubectl patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"
  }
}
