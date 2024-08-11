module "helm_charts" {
  source = "./modules/kubernetes"


  cluster_name = local.cluster_name

  // External Helm Charts
  helm_charts = {
    "aws-load-balancer-controller" = {
      repository  = "https://aws.github.io/eks-charts"
      chart       = "aws-load-balancer-controller"
      version     = "1.7.1"
      namespace   = "kube-system"
      values      = []
      sets        = [
        {
          name  = "clusterName"
          value = local.cluster_name
        },
        {
          name  = "serviceAccount.create"
          value = "true"
        },
        {
          name  = "serviceAccount.name"
          value = "aws-load-balancer-controller"
        }
      ]
    },

    "argocd" = {
      repository  = "https://argoproj.github.io/argo-helm"
      chart       = "argo-cd"
      version     = "7.4.2"
      namespace   = "argocd"
      values      = [
        "${file("./files/argocd.values.yml")}"
      ]
      sets        = []
    },

    "external-secrets" = {
      repository  = "https://charts.external-secrets.io"
      chart       = "external-secrets"
      namespace   = "external-secrets-operator"
      version     = "0.10.0"
      values      = []
      sets        = []
    },

    "external-dns" = {
      repository  = "https://kubernetes-sigs.github.io/external-dns/"
      chart       = "external-dns"
      namespace   = "external-dns"
      version     = "1.14.5"
      values      = []
      sets        = [
        {
          name  = "txtOwnerId"
          value = "Z02600892A63D9HDGI5KX"
        },
        {
          name  = "domainFilters[0]"
          value = "alejandroarias.co"
        }
      ]
    }
  }

  // Kubernetes manifests
  manifests = {
    "node-app" = {
      apiVersion = "v1"
      kind       = "Namespace"
      metadata = {
        name      = "node-app"
      }
    }

    "ArgoSecretStore" = {
      apiVersion = "external-secrets.io/v1beta1"
      kind       = "SecretStore"
      metadata = {
        name      = "argo-secret-store"
        namespace = "argocd"
      }
      spec = {
        provider = {
          aws = {
            service = "SecretsManager"
            region  = local.aws_region
          }
        }
      }
    }

    "NodeAppSecretStore" = {
      apiVersion = "external-secrets.io/v1beta1"
      kind       = "SecretStore"
      metadata = {
        name      = "nodeapp-secret-store"
        namespace = "node-app"
      }
      spec = {
        provider = {
          aws = {
            service = "SecretsManager"
            region  = local.aws_region
          }
        }
      }
    }

    "ArgoRoot" = {
      apiVersion = "argoproj.io/v1alpha1"
      kind       = "Application"
      metadata = {
        name       = "root"
        namespace  = "argocd"
        finalizers = ["resources-finalizer.argocd.argoproj.io"]
      }
      spec = {
        destination = {
          server = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        project = "default"
        source = {
          path = "argocd-apps"
          repoURL = "https://github.com/alejandroariaszuluaga/devsecops-sre-challenge.git"
          targetRevision = "HEAD"
        }
        syncPolicy = {
          automated = {
            prune = true
            selfHeal = true
          }
        }
      }
    }
  }

  external_secrets = {
    "argocd-apps-repo" = {
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
      secret_store_name = "argo-secret-store"
    },

    "postgres-secret" = {
      namespace = "node-app"
      secret_store_name = "nodeapp-secret-store"
      labels = {}
    }
  }
}
