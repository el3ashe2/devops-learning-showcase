variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

# Cloudflare Variables
variable "cloudflare_account_id" {
  description = "Cloudflare account ID - required for Workers deployment. Replace with your actual account ID."
  type        = string
  default     = "YOUR_CLOUDFLARE_ACCOUNT_ID"
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone name (domain). Replace with your actual domain."
  type        = string
  default     = "example.com"
}

variable "cloudflare_record_name" {
  description = "DNS record name for EKS ingress (e.g., 'app' for app.example.com or '@' for root domain)"
  type        = string
  default     = "app"
}

variable "eks_alb_dns_name" {
  description = "EKS ALB DNS name - will be set after EKS deployment"
  type        = string
  default     = "REPLACE_WITH_ALB_DNS_NAME"
}
