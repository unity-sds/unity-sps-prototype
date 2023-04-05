# Shared values between local and remote deployment
release = "23.1"

docker_images = {
  hysds_core         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
  hysds_ui           = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1"
  hysds_mozart       = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
  hysds_grq2         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1"
  hysds_verdi        = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1"
  hysds_factotum     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1"
  ades_wpst_api      = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api-mcp-dev-tmp:unity-v0.0.1"
  sps_api            = "ghcr.io/unity-sds/unity-sps-prototype/sps-api-fork:unity-v0.0.1"
  sps_hysds_pge_base = "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:unity-v0.0.1"
  logstash           = "docker.elastic.co/logstash/logstash:7.10.2"
  minio              = "minio/minio:RELEASE.2022-03-17T06-34-49Z"
  mc                 = "minio/mc:RELEASE.2022-03-13T22-34-00Z"
  rabbitmq           = "rabbitmq:3-management"
  busybox            = "k8s.gcr.io/busybox"
  redis              = "redis:latest"
}

venue                                         = "dev"
eks_cluster_name                              = "<INSERT-EKS-CLUSTER-NAME>"
kubeconfig_filepath                           = "<INSERT-EKS-CLUSTER-KUBECONFIG-PATH>"
uads_development_efs_fsmt_id                  = "fsmt-06d161d46a1b16cb6"
default_group_node_group_name                 = "dafaultgroupNodeGroup"
default_group_node_group_launch_template_name = "eksctl-unity-dev-sps-hysds-eks-1-nodegroup-dafaultgroupNodeGroup"
elb_subnet                                    = "subnet-087b54673c7549e2d"
