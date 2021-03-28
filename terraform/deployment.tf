# Create external DNS records if needed:
resource "aws_route53_zone" "assignment" {
  name    = var.dns_zone
  comment = "DNS zone for the assignment"
  count   = substr(var.dns_zone, length(var.dns_zone) - 6, length(var.dns_zone)) != ".local" ? 1 : 0
}

resource "aws_route53_record" "assignment_wildcard" {
  zone_id = aws_route53_zone.assignment[0].zone_id
  name    = format("*.%s", aws_route53_zone.assignment[0].name)
  type    = "A"
  ttl     = 600
  records = [var.kube_cluster_ip]
  count   = substr(var.dns_zone, length(var.dns_zone) - 6, length(var.dns_zone)) != ".local" ? 1 : 0
}

# Create required namespaces:
resource "kubernetes_namespace" "core" {
  metadata {
    name = "assignment-core"
  }
}

resource "kubernetes_namespace" "infrastructure" {
  metadata {
    name = "assignment-infrastructure"
  }
}

resource "kubernetes_namespace" "applications" {
  metadata {
    name = "assignment-applications"
  }
}

# Deploy the core components(s):
resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.versions.ingress_nginx
  values = [
    file(format("%s/../config/%s", path.root, "nginx.yaml"))
  ]
  namespace = kubernetes_namespace.core.id
  count     = var.deploy_ingress_nginx ? 1 : 0
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.versions.cert_manager
  values = [
    file(format("%s/../config/%s", path.root, "cert-manager.yaml"))
  ]
  namespace = kubernetes_namespace.core.id
}

# Deploy the client-facing application(s):
resource "helm_release" "juice-shop" {
  name       = "juice-shop"
  repository = "https://charts.securecodebox.io"
  chart      = "juice-shop"
  version    = var.versions.juice_shop
  values = [
    file(format("%s/../config/%s", path.root, "juice-shop.yaml"))
  ]
  set {
    name  = "ingress.hosts[0].host"
    value = format("juice-shop%s", var.dns_zone)
  }
  set {
    name  = "ingress.hosts[0].paths"
    value = "{}"
  }
  set {
    name  = "ingress.tls[0].hosts"
    value = format("{juice-shop%s}", var.dns_zone)
  }
  namespace = kubernetes_namespace.applications.id
}

# Deploy the infrastructure application(s):
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.versions.grafana
  values = [
    file(format("%s/../config/%s", path.root, "grafana.yaml"))
  ]
  set {
    name  = "ingress.hosts"
    value = format("{grafana%s}", var.dns_zone)
  }
  set {
    name  = "adminPassword"
    value = var.grafana_password
  }
  set {
    name = "grafana.ini.server.root_url"
    value = format("http://{grafana%s}", var.dns_zone)
  }
  namespace = kubernetes_namespace.infrastructure.id
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.versions.prometheus
  values = [
    file(format("%s/../config/%s", path.root, "prometheus.yaml"))
  ]
  set {
    name  = "server.ingress.hosts"
    value = format("{prometheus%s}", var.dns_zone)
  }
  namespace = kubernetes_namespace.infrastructure.id
}
