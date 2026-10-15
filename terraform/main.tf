terraform {
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

# Provider configurado para ejecutar contra tu clúster local
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Creación del namespace requerido para el despliegue
resource "kubernetes_namespace" "meditriage_ns" {
  metadata {
    name = "meditriage"
  }
}