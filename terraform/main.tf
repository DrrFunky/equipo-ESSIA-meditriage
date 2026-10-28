terraform {
  required_version = ">= 1.6"

  backend "kubernetes" {
    secret_suffix = "meditriage-state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}

# Provider configurado para ejecutar contra el clúster local
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace requerido para el despliegue
resource "kubernetes_namespace" "meditriage_ns" {
  metadata {
    name = "meditriage"
  }
}

# Secret placeholder: el valor real se carga cuando exista la BD
resource "kubernetes_secret" "meditriage_secrets" {
  metadata {
    name      = "meditriage-secrets"
    namespace = kubernetes_namespace.meditriage_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/part-of" = "meditriage"
    }
  }

  type = "Opaque"

  data = {
    DATABASE_URL = "CHANGEME"
  }

  lifecycle {
    ignore_changes = [data] # Terraform no pisa el valor real cuando se cargue
  }
}