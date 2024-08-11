variable "cluster_name" {
  type = string
}

variable "helm_charts" {
  type = map(object({
    repository = optional(string, "")
    chart      = optional(string, "")
    version    = optional(string, "")
    sets       = optional(list(map(string)),[])
    values     = optional(list(string),[])
    namespace  = optional(string, "")
  }))
  default = {}
}

variable "manifests" {
  type    = any
  default = {}
}

variable "external_secrets" {
  type    = any
  default = {}
}
