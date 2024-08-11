module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.instance_types
    iam_role_additional_policies = {
      EBS     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      ELB     = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      Shield  = "arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"
      EC2     = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      Secrets = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
      R53     = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
    }
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size = 1
      max_size = 10

      instance_types = var.instance_types
      # capacity_type  = "SPOT"
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"
  access_entries = var.access_entries

  tags = var.tags
}
