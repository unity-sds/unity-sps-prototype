# Required
release             = "23.1"
deployment_name     = "<INSERT-UNIQUE-DEPLOYMENT-NAME>"
eks_cluster_name    = "<INSERT-EKS-CLUSTER-NAME>"
kubeconfig_filepath = "<INSERT-EKS-CLUSTER-KUBECONFIG-PATH>"

# Optional if EKS cluster deployment included SSM Param configuration and account SSM Params are configured
venue                                         = "dev"
uads_development_efs_fsmt_id                  = "fsmt-06d161d46a1b16cb6"
default_group_node_group_name                 = "defaultgroupNodeGroup"
default_group_node_group_launch_template_name = "<INSERT-EKS-DEFAULT-NODE-GROUP-LAUNCH-TEMPLATE-NAME>"
elb_subnets                                   = "subnet-087b54673c7549e2d"
