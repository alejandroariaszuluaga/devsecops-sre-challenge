module "vpc" {
  source = "cloudposse/vpc/aws"
  version                          = "2.1.0"
  namespace                        = var.project_name
  ipv4_primary_cidr_block          = "10.0.0.0/16"
}

output "igw_id" {
  value = module.vpc.igw_id
}

module "dynamic_subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  version            = "0.39.0"
  namespace          = var.project_name
  availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = "10.0.0.0/16"
}
