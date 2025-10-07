# Cloudflare Provider Configuration
# API Token should be set via environment variable: export CLOUDFLARE_API_TOKEN=<your_token>

provider "cloudflare" {
  # API token is read from CLOUDFLARE_API_TOKEN environment variable
}

# Data source to get the Cloudflare zone ID
data "cloudflare_zone" "main" {
  name = var.cloudflare_zone_name
}

# DNS CNAME record for EKS Ingress/ALB
# This creates a CNAME record pointing to your EKS load balancer
# Update the value with your actual ALB DNS name after deployment
resource "cloudflare_record" "eks_ingress" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.cloudflare_record_name
  type    = "CNAME"
  value   = var.eks_alb_dns_name
  ttl     = 1  # 1 = automatic
  proxied = true
  comment = "EKS Ingress/ALB endpoint"
}

# Cloudflare Worker Script
# Deploy a sample worker to your domain
resource "cloudflare_worker_script" "app_worker" {
  account_id = var.cloudflare_account_id
  name       = "my-app-worker"
  content    = file("${path.module}/worker.js")
}

# Worker Route - Map worker to specific URL patterns
# This routes all traffic through the worker for processing
resource "cloudflare_worker_route" "app_route" {
  zone_id     = data.cloudflare_zone.main.id
  pattern     = "${var.cloudflare_zone_name}/*"
  script_name = cloudflare_worker_script.app_worker.name
}
