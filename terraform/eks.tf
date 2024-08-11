module "eks" {
  source = "./modules/eks"

  cluster_version          = "1.29"
  cluster_name             = local.cluster_name
  instance_types           = ["t3.medium"]
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  access_entries = {
    access_control = {
      cluster_name      = local.cluster_name
      principal_arn     = "arn:aws:iam::289667274164:user/alejo"
      kubernetes_groups = ["system:masters"]
      policy_arn        = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
    }
  }

  tags = var.required_tags
}
