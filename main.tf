# NIS2 Compliance Framework
# Modules will be called here progressively

module "iam" {
      source       = "./modules/iam"
      project_name = var.project_name
    }