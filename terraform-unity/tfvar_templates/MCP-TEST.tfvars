release                                       = "23.1"
venue                                         = "test"
eks_cluster_name                              = "<INSERT-EKS-CLUSTER-NAME>"
kubeconfig_filepath                           = "<INSERT-EKS-CLUSTER-KUBECONFIG-PATH>"
uads_development_efs_fsmt_id                  = "fsmt-06c1de455bed6a67b"
eks_node_groups                               = { default = ["defaultgroupNodeGroup"], custom = [] }
default_group_node_group_launch_template_name = "<INSERT-EKS-DEFAULT-NODE-GROUP-LAUNCH-TEMPLATE-NAME>"
subnets                                       = { public = [], private = ["subnet-059bc4f467275b59d", "subnet-0ebdd997cc3ebe58d"] }
