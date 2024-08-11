data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", var.cluster_name, "--output","json"]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", var.cluster_name, "--output","json"]
  }
  token                  = data.aws_eks_cluster_auth.default.token
}

resource "helm_release" "charts" {
  for_each         = merge(local.helm_charts,var.helm_charts)
  name             = each.key
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  values           = each.value.values
  wait             = false
  create_namespace = true

  dynamic "set" {
    for_each = each.value.sets
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "kubernetes_manifest" "manifests" {
  for_each = merge(local.manifests,var.manifests)
  manifest = each.value
  depends_on = [ helm_release.charts ]
}

resource "kubernetes_manifest" "external_secrets" {
  for_each = var.external_secrets
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
      labels    = each.value.labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = each.value.secret_store_name
        kind = "SecretStore"
      }
      target = {
        name           = each.key
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = each.key
          }
        }
      ]
    }
  }
  depends_on = [ helm_release.charts , kubernetes_manifest.manifests]
}
