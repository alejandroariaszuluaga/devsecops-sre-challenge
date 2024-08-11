module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "devsecops-code-challenge-sg"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access from VPC CIDR"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access from bastion.prod.quext.io"
      cidr_blocks = "44.203.24.27/32"
    },
  ]
  egress_with_cidr_blocks  = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS outbound"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Access to Public MySQL DBs"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Access to Public Postgres DBs"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.required_tags
}
