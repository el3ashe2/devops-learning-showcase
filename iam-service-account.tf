# Reference to IAM user for service account authentication
# This demonstrates using an IAM user instead of IRSA roles for cluster autoscaler 
# and load balancer controller (for learning purposes only)
# Note: In production, use IRSA (IAM Roles for Service Accounts) instead
# The IAM user must have appropriate policies attached to perform:
# - AutoScaling permissions for cluster-autoscaler
# - ELB and EC2 permissions for load-balancer-controller

# Output the IAM user ARN for reference
output "iam_user_arn" {
  description = "IAM user ARN used for service accounts (educational example - use IRSA in production)"
  value       = "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:user/YOUR_IAM_USER"
}
