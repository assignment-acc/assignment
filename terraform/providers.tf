provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_credentials.access_key
  secret_key                  = var.aws_credentials.secret_key
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config
    config_context = var.kube_context
  }
}

provider "kubernetes" {
  config_path    = var.kube_config
  config_context = var.kube_context
}
