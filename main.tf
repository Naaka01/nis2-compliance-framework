# NIS2 Compliance Framework
# Modules will be called here progressively

module "iam" {
      source       = "./modules/iam"
      project_name = var.project_name
    }

module "logging" {
      source       = "./modules/logging"
      project_name = var.project_name
  region       = var.aws_region
    }