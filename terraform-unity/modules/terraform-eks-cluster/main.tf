data "aws_caller_identity" "current" {}

module "unity-eks" {
  source          = "git@github.com:unity-sds/unity-cs-infra.git//terraform-unity-eks_module"
  deployment_name = var.cluster_name

  nodegroups = {
    defaultGroup = {
      instance_types = ["m5.xlarge"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }
  }
  aws_auth_roles = [{
    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mcp-tenantOperator"
    username = "admin"
    groups   = ["system:masters"]
  }]

  cluster_version = "1.27"
}

# add extra policies as inline policy
resource "aws_iam_role_policy" "sps_airflow_eks_inline_policy" {
  name   = "sps_airflow_eks_inline_policy"
  role   = module.unity-eks.cluster_iam_role
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:CreateSecurityGroup",
                "ec2:Describe*",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        }
    ]
}
EOT
}


data "aws_eks_cluster" "cluster" {
  name       = var.cluster_name
  depends_on = [module.unity-eks]
}

data "aws_eks_cluster_auth" "auth" {
  name       = var.cluster_name
  depends_on = [module.unity-eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.auth.token
}