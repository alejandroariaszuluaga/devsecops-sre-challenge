variable "vpc_id" {}

variable "subnet_ids" {
  type = list(string)
}

variable "control_plane_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "instance_types" {
  type    = list(string)
  default = ["t3a.medium"]
}

variable "access_entries" {
  type    = any
  default = {}
}

variable "ami_filter" {
  type    = string
  default = "amzn2-ami-kernel-5.10"
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aws_auth_roles" {
  type    = list(any)
  default = []
}
variable "aws_auth_users" {
  type    = list(any)
  default = []
}
variable "aws_auth_accounts" {
  type    = list(any)
  default = []
}
