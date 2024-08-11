variable "required_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Stack       = "DevSecOps-Challenge"
    Description = "Managed by Terraform"
  }
}

