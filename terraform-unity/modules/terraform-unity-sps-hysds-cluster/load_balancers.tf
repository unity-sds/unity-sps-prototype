# This security group should be added to all load balancers to allow traffic to the EKS cluster
resource "aws_security_group" "shared-lb-sg"{
  name = "${var.service_area}-shared-lb-sg-${local.counter}"
  description = "Shared sg for all ${var.service_area}-${local.counter} load balancers, allows creation of sg rule on cluster security group that affects all load balancers"
  vpc_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  egress {
    protocol = "All"
    from_port = 0 # terraform's version of specifying "all"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This security group rule adds the shared load balancer security group to the eks cluster security group so that load balancers can forward traffic to eks
resource "aws_vpc_security_group_ingress_rule" "sps-nlb-sgr" {
  for_each = toset(data.aws_eks_cluster.sps-cluster.vpc_config[0].security_group_ids)
  security_group_id = each.key

  description = "${var.service_area}-${local.counter} share nlb sgr, allows ingress to cluster form load balancers"
  ip_protocol = -1 # all protocols, all ports
  referenced_security_group_id = aws_security_group.shared-lb-sg.id # shared load balancer security group source
}

resource "aws_api_gateway_vpc_link" "ades-wpst-api-gateway-vpc-link" {
  name = "unity-${var.service_area}-wpst-${local.counter}"
  description = "VPC Link for ades-wpst-api load balancer"

  target_arns = [aws_lb.ades-wpst-load-balancer.arn]
}

# Network Load Balancer for wpst
resource "aws_lb" "ades-wpst-load-balancer" {
  name               = "unity-${var.service_area}-wpst-nlb-${local.counter}"
  internal           = true 
  load_balancer_type = "network"

  security_groups = toset([aws_security_group.shared-lb-sg.id, aws_security_group.ades-wpst-nlb-sg.id])
  
  # Define subnets for the NLB
  subnets = toset(split(",", var.elb_subnets))
}

# target group for the wpst NLB
resource "aws_lb_target_group" "ades-wpst-target-group" {
  name     = "unity-${var.service_area}-wpst-tg-${local.counter}"
  port     = 5000
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id  
}

# listener for the wpst NLB
resource "aws_lb_listener" "ades-wpst-k8s-service" {
  load_balancer_arn = aws_lb.ades-wpst-load-balancer.arn
  port = var.service_port_map.ades_wpst_api_service
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ades-wpst-target-group.arn 
  }
}

# aws load balancer controller uses TargetGroupBinding to configure the target group to use the wpst service
resource "kubernetes_manifest" "ades-wpst-target-group-binding"{
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind" = "TargetGroupBinding"
    "metadata" = {
      "name" = "wpst-targetgroup-binding"
      "namespace" = kubernetes_namespace.unity-sps.metadata[0].name
    }
    "spec" = {
      "serviceRef" = {
        "name" = "ades-wpst-api"
        "port" = var.service_port_map.ades_wpst_api_service
      }
      "targetGroupARN" = aws_lb_target_group.ades-wpst-target-group.arn
      "targetType" = "ip"
    }
  }
  depends_on = [helm_release.aws-load-balancer-controller]
}

# wpst specific security group
resource "aws_security_group" "ades-wpst-nlb-sg" {
  name = "${var.service_area}-wpst-nlb-sg-${local.counter}"
  description = "sg for all ${var.service_area}-wpst load balancer"
  vpc_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  ingress {
    protocol = "TCP"
    from_port = var.service_port_map.ades_wpst_api_service
    to_port = var.service_port_map.ades_wpst_api_service
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "TCP"
    from_port = 0 # terraform's version of specifying "all"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_api_gateway_vpc_link" "jobsdb-gateway-vpc-link" {
  name = "unity-${var.service_area}-jobsdb-${local.counter}"
  description = "VPC Link for jobsdb load balancer"

  target_arns = [aws_lb.jobsdb-load-balancer.arn]
}

# Network Load Balancer for jobsdb
resource "aws_lb" "jobsdb-load-balancer" {
  name               = "unity-${var.service_area}-jobsdb-nlb-${local.counter}"
  internal           = true 
  load_balancer_type = "network"

  security_groups = toset([aws_security_group.shared-lb-sg.id, aws_security_group.jobsdb-nlb-sg.id])
  
  # Define subnets for the NLB
  subnets = toset(split(",", var.elb_subnets))
}

# target group for the jobsdb NLB
resource "aws_lb_target_group" "jobsdb-target-group" {
  name     = "unity-${var.service_area}-jobsdb-tg-${local.counter}"
  port     = 9200
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id  
}

# listener for the NLB
resource "aws_lb_listener" "jobsdb-k8s-service" {
  load_balancer_arn = aws_lb.jobsdb-load-balancer.arn
  port = var.service_port_map.jobs_es
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.jobsdb-target-group.arn 
  }
}

# aws load balancer controller uses TargetGroupBinding to configure the target group to use the service
resource "kubernetes_manifest" "jobsdb-target-group-binding"{
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind" = "TargetGroupBinding"
    "metadata" = {
      "name" = "jobsdb-targetgroup-binding"
      "namespace" = kubernetes_namespace.unity-sps.metadata[0].name
    }
    "spec" = {
      "serviceRef" = {
        "name" = "jobs-es"
        "port" = var.service_port_map.jobs_es
      }
      "targetGroupARN" = aws_lb_target_group.jobsdb-target-group.arn
      "targetType" = "ip"
    }
  }
  depends_on = [helm_release.aws-load-balancer-controller]
}

# lb specific security group
resource "aws_security_group" "jobsdb-nlb-sg" {
  name = "${var.service_area}-jobsdb-nlb-sg-${local.counter}"
  description = "sg for ${var.service_area}-jobsdb load balancer"
  vpc_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  ingress {
    protocol = "TCP"
    from_port = var.service_port_map.jobs_es
    to_port = var.service_port_map.jobs_es
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "TCP"
    from_port = 0 # terraform's version of specifying "all"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_api_gateway_vpc_link" "sps-api-gateway-vpc-link" {
  name = "unity-${var.service_area}-sps-api-${local.counter}"
  description = "VPC Link for sps-api load balancer"

  target_arns = [aws_lb.sps-api-load-balancer.arn]
}

# Network Load Balancer for wpst
resource "aws_lb" "sps-api-load-balancer" {
  name               = "unity-${var.service_area}-sps-api-nlb-${local.counter}"
  internal           = true 
  load_balancer_type = "network"

  security_groups = toset([aws_security_group.shared-lb-sg.id, aws_security_group.sps-api-nlb-sg.id])
  
  # Define subnets for the NLB
  subnets = toset(split(",", var.elb_subnets))
}

# target group for the wpst NLB
resource "aws_lb_target_group" "sps-api-target-group" {
  name     = "unity-${var.service_area}-sps-api-tg-${local.counter}"
  port     = 80
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id  
}

# listener for the wpst NLB
resource "aws_lb_listener" "sps-api-k8s-service" {
  load_balancer_arn = aws_lb.sps-api-load-balancer.arn
  port = var.service_port_map.sps_api_service
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.sps-api-target-group.arn 
  }
}

# aws load balancer controller uses TargetGroupBinding to configure the target group to use the wpst service
resource "kubernetes_manifest" "sps-api-target-group-binding"{
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind" = "TargetGroupBinding"
    "metadata" = {
      "name" = "sps-api-targetgroup-binding"
      "namespace" = kubernetes_namespace.unity-sps.metadata[0].name
    }
    "spec" = {
      "serviceRef" = {
        "name" = "sps-api"
        "port" = var.service_port_map.sps_api_service
      }
      "targetGroupARN" = aws_lb_target_group.sps-api-target-group.arn
      "targetType" = "ip"
    }
  }
  depends_on = [helm_release.aws-load-balancer-controller]
}

# wpst specific security group
resource "aws_security_group" "sps-api-nlb-sg" {
  name = "${var.service_area}-sps-api-nlb-sg-${local.counter}"
  description = "sg for all ${var.service_area}-sps-api load balancer"
  vpc_id = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  ingress {
    protocol = "TCP"
    from_port = var.service_port_map.sps_api_service
    to_port = var.service_port_map.sps_api_service
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "TCP"
    from_port = 0 # terraform's version of specifying "all"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aws Load Balancer Controller Helm Chart
resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  version = "1.6.1"
  namespace = "kube-system"
  set {
    name = "clusterName"
    value = data.aws_eks_cluster.sps-cluster.name
  }
  set {
    name = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name = "region"
    value = var.region
  }
  set {
    name = "vpcId"
    value = data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id
  }
  
}

# # Custom Resource Definition for AWS Load Balancer Controller
# data "http" "load-balancer-controller-custom-resource-definition-yaml"{
#   url = "https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml"
# }

# resource "kubernetes_manifest" "load-balancer-controller-custom-resource-definition" {
#   manifest = yamldecode(data.http.load-balancer-controller-custom-resource-definition-yaml.response_body)
# }

# Create IAM OIDC provider for EKS cluster so we can add AWS Load Balancer Controller
# data "tls_certificate" "eks-cluster-oidc-server-certificate"{
#   url = data.aws_eks_cluster.sps-cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks-cluster-openidc-provider" {
#   url = data.aws_eks_cluster.sps-cluster.identity[0].oidc[0].issuer

#   client_id_list = ["sts.amazonaws.com"]

#   thumbprint_list = [data.tls_certificate.eks-cluster-oidc-server-certificate.certificates[0].sha1_fingerprint]
# }

resource "kubernetes_service_account" "aws-load-balancer-controller-service-account"{
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn": aws_iam_role.aws-load-balancer-controller-role.arn
    }
    labels = {
      "app.kubernetes.io/component": "controller"
      "app.kubernetes.io/name": "aws-load-balancer-controller"
    }
  }
}

locals {
  openidc_provider_domain_name = trimprefix(data.aws_eks_cluster.sps-cluster.identity[0].oidc[0].issuer, "https://") 
}

data "aws_iam_policy" "aws-managed-load-balancer-policy"{
  arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"  
}

# AwsLoadBalancerController Role and Policy from https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
resource "aws_iam_role" "aws-load-balancer-controller-role"{
  name = "${var.service_area}-AwsLoadBalancerControllerRole-${local.counter}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.openidc_provider_domain_name}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${local.openidc_provider_domain_name}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
                    "${local.openidc_provider_domain_name}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })

  managed_policy_arns = [aws_iam_policy.aws-load-balancer-controller-policy.arn]
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}

resource "aws_iam_role_policy_attachment" "aws-load-balancer-policy-attachment"{
  role = aws_iam_role.aws-load-balancer-controller-role.name
  policy_arn = data.aws_iam_policy.aws-managed-load-balancer-policy.arn
}

resource "aws_iam_policy" "aws-load-balancer-controller-policy"{
  name = "${var.service_area}-AwsLoadBalancerControllerPolicy-${local.counter}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
  })
}