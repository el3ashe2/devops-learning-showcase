# DevOps Learning Showcase

> **⚠️ EDUCATIONAL PURPOSE ONLY**  
> This repository is a **public learning project** designed to demonstrate DevOps and cloud infrastructure concepts.  
> All sensitive information has been sanitized. Do not use in production without proper security review and configuration.

## About This Project

This repository contains complete Infrastructure as Code (IaC) for deploying an Amazon EKS cluster on AWS with Kubernetes configurations, monitoring tools, and Cloudflare integration. It serves as a comprehensive example of modern DevOps practices and cloud-native technologies.

## Technologies & Services Used

This project demonstrates proficiency with the following technologies:

### Cloud & Infrastructure
- **AWS (Amazon Web Services)** - Primary cloud provider
- **Amazon EKS (Elastic Kubernetes Service)** - Managed Kubernetes cluster
- **VPC (Virtual Private Cloud)** - Network isolation and security
- **IAM (Identity and Access Management)** - AWS permissions and authentication
- **EC2** - Compute instances for worker nodes
- **ELB (Elastic Load Balancing)** - Traffic distribution

### Kubernetes & Container Orchestration
- **Kubernetes** - Container orchestration platform
- **Helm** - Kubernetes package manager
- **Docker** - Containerization (implied through Kubernetes)
- **kubectl** - Kubernetes command-line tool

### Infrastructure as Code (IaC)
- **Terraform** - Infrastructure provisioning and management
- **HCL (HashiCorp Configuration Language)** - Terraform configuration syntax

### Networking & DNS
- **Cloudflare** - CDN and DNS management
- **Cloudflare Workers** - Serverless edge computing
- **DNS** - Domain name system configuration

### Monitoring & Observability
- **DataDog** - Application Performance Monitoring (APM) and logging
- **Metrics Collection** - Resource utilization tracking

### Autoscaling & Resource Management
- **Cluster Autoscaler** - Automatic node scaling
- **HPA (Horizontal Pod Autoscaler)** - Automatic pod scaling

### Security & Access Control
- **RBAC (Role-Based Access Control)** - Kubernetes authorization
- **Network Policies** - Pod-to-pod communication rules
- **Security Groups** - AWS firewall rules

### Development & Automation
- **Git** - Version control
- **CI/CD** - Continuous Integration/Continuous Deployment concepts
- **Jenkins** - (Referenced for potential pipeline automation)
- **Python** - (Potential scripting language)
- **JavaScript** - Cloudflare Workers implementation

### Operating Systems & Tools
- **Linux** - Primary operating system
- **Bash** - Shell scripting

### Additional Databases & Storage (Referenced)
- **CockroachDB** - Distributed SQL database (potential use case)
- **Redis** - In-memory data store (potential use case)

## Directory Structure

```
.
├── versions.tf                 # Terraform version and provider requirements
├── variables.tf                # Input variables and their default values
├── vpc.tf                      # VPC and networking configuration
├── eks-cluster.tf              # EKS cluster and node group configuration
├── iam-service-account.tf      # IAM user reference for Kubernetes service accounts
├── outputs.tf                  # Output values from Terraform
├── cloudflare.tf               # Cloudflare DNS automation
├── worker.js                   # Sample Cloudflare Worker script
└── helm-charts/                # Helm chart configurations
    ├── cluster-autoscaler/     # Cluster autoscaling
    │   └── values.yaml
    ├── hpa/                    # Horizontal Pod Autoscaler
    │   └── values.yaml
    ├── network-policy/         # Network policies for security
    │   └── values.yaml
    ├── rbac/                   # Role-based access control
    │   └── values.yaml
    └── datadog/                # Monitoring and observability
        └── values.yaml
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- Helm >= 3.0
- AWS account with permissions to create EKS clusters, VPCs, and IAM roles
- **Cloudflare API Token** (for DNS automation)

## Quick Start

### 1. Initialize Terraform

```bash
cd /path/to/repo
terraform init
```

### 2. Set Environment Variables

```bash
# AWS credentials (if not already configured)
export AWS_ACCESS_KEY_ID=<your_aws_key>
export AWS_SECRET_ACCESS_KEY=<your_aws_secret>

# Cloudflare API Token
export CLOUDFLARE_API_TOKEN=<your_token>
```

### 3. Review and Customize Variables

Edit `variables.tf` or create a `terraform.tfvars` file to customize:

```hcl
region                   = "us-east-1"
cluster_name             = "my-eks-cluster"
vpc_cidr                 = "10.0.0.0/16"

# Cloudflare DNS settings
cloudflare_account_id    = "YOUR_CLOUDFLARE_ACCOUNT_ID"
cloudflare_zone_name     = "example.com"
cloudflare_record_name   = "app"  # Creates app.example.com
eks_alb_dns_name         = "REPLACE_WITH_ALB_DNS_NAME"  # Update after EKS deployment
```

### 4. Plan and Apply Infrastructure

```bash
terraform plan
terraform apply
```

### 5. Configure kubectl

After successful deployment:

```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
kubectl get nodes
```

### 6. Update DNS with ALB Endpoint

After deploying your application and obtaining the ALB DNS name:

1. Get the ALB DNS name from your Kubernetes ingress or service
2. Update the `eks_alb_dns_name` variable in `variables.tf` or `terraform.tfvars`
3. Run `terraform apply` again to update the Cloudflare DNS record

## Infrastructure Components

### Terraform Modules

- **VPC**: Creates a custom VPC with public and private subnets across 3 availability zones
- **EKS Cluster**: Deploys Kubernetes 1.29 cluster with managed node groups
- **IAM Service Accounts**: Example of IAM user for service account authentication (use IRSA in production)
- **Cloudflare DNS**: Automates DNS record creation for EKS ingress endpoints

### Helm Charts

#### Cluster Autoscaler
Automatically adjusts the number of nodes in your cluster based on pod resource requirements.

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  -f helm-charts/cluster-autoscaler/values.yaml \
  --namespace kube-system
```

#### Horizontal Pod Autoscaler (HPA)
Scales pods based on CPU and memory utilization.

```bash
kubectl apply -f helm-charts/hpa/values.yaml
```

#### Network Policies
Implements network segmentation and security rules.

```bash
kubectl apply -f helm-charts/network-policy/values.yaml
```

#### RBAC Configuration
Role-based access control for Kubernetes resources.

```bash
kubectl apply -f helm-charts/rbac/values.yaml
```

#### Datadog Monitoring
Provides comprehensive monitoring, logging, and APM.

```bash
helm repo add datadog https://helm.datadoghq.com
helm install datadog datadog/datadog \
  -f helm-charts/datadog/values.yaml \
  --namespace monitoring --create-namespace
```

**Note**: Update Datadog API and APP keys in `helm-charts/datadog/values.yaml` before deployment.

## Configuration Details

### Network Architecture

- VPC CIDR: 10.0.0.0/16
- Private Subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- Public Subnets: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
- NAT Gateway: Single NAT gateway for cost optimization

### EKS Cluster Settings

- Kubernetes Version: 1.29
- Node Instance Type: t3.medium (configurable)
- Min Nodes: 1
- Max Nodes: 4
- Desired Nodes: 2

### Security Features

- Private API endpoint available
- Network policies for pod isolation
- IAM authentication for secure AWS service access
- Security groups for node-to-node and pod communication
- RBAC for Kubernetes resource access control

### Cloudflare Configuration

- DNS automation via Terraform
- Cloudflare Workers for edge computing
- CDN and security features enabled
- Automatic TTL management

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Ensure you have backups of any critical data.

## Troubleshooting

### Cannot connect to cluster

```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```

### Nodes not scaling

Check cluster autoscaler logs:

```bash
kubectl logs -n kube-system -l app=cluster-autoscaler
```

### Pods not communicating

Review network policies:

```bash
kubectl get networkpolicies --all-namespaces
```

### Cloudflare DNS not updating

1. Verify the `CLOUDFLARE_API_TOKEN` environment variable is set:
   ```bash
   echo $CLOUDFLARE_API_TOKEN
   ```
2. Check that the token has the correct permissions for your zone
3. Verify the zone name in `variables.tf` matches your Cloudflare account
4. Review Terraform output for Cloudflare provider errors

## Learning Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)

## Contributing

This is a learning project, but contributions are welcome! Please submit pull requests or open issues for bugs, improvements, or additional examples.

## License

This project is licensed under the MIT License.

## Disclaimer

**This repository is for educational and learning purposes only.**

All sensitive information (API keys, credentials, account IDs, domain names) has been removed or replaced with placeholders. Before using this code:

1. Replace all placeholder values with your actual configuration
2. Review all security settings and adjust for your use case
3. Never commit real credentials or sensitive information to version control
4. Use proper secret management tools (AWS Secrets Manager, HashiCorp Vault, etc.) in production
5. Implement IRSA (IAM Roles for Service Accounts) instead of IAM users for production workloads

## Support

For questions or issues related to this learning project, please open an issue in the GitHub repository.
