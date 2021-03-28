# Kubernetes configuration variables:
variable "kube_config" {
  type        = string
  description = "Path to Kubernetes configuration file."
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Name of Kubernetes cluster context to use."
  default     = "kind-assignment"
}

variable "kube_cluster_ip" {
  type        = string
  default     = "127.0.0.1"
  description = "IP (either local or external one) of the Kubernetes cluster."
}

# AWS configuration variables:
variable "aws_region" {
  type        = string
  description = "Name of AWS region to use for external DNS records."
  default     = "eu-west-1"
}

variable "aws_credentials" {
  type = map(string)
  default = {
    access_key = "CHANGE_ME"
    secret_key = "CHANGE_ME"
  }
  description = "Credentials with access to created records in AWS Route53."
  sensitive   = true
}

# Application versions:
variable "versions" {
  type = map(string)
  default = {
    ingress_nginx = ""
    juice_shop    = ""
    grafana       = ""
    prometheus    = ""
    cert_manager  = ""
  }
  description = "Helm chart versions to deploy."
}

// Grafana configuration:
variable "grafana_password" {
  type        = string
  description = "Password for Grafana administrator account."
  sensitive   = true
}

# Other:
variable "dns_zone" {
  type        = string
  description = "Zone to create DNS records for deployed applications in."
  default     = ".assignment.local"
  validation {
    condition = (
      substr(var.dns_zone, 0, 1) == "."
    )
    error_message = "DNS Zone should be prefixed with a dot (.)."
  }
}

variable "deploy_ingress_nginx" {
  type        = bool
  description = "Whether the Nginx-based ingress should be deployed to the cluster."
  default     = true
}
