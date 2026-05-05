# ─────────────────────────────
# EKS Cluster Outputs
# ─────────────────────────────
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# ─────────────────────────────
# VPC Outputs
# ─────────────────────────────
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# ─────────────────────────────
# Kubeconfig
# ─────────────────────────────
output "kubeconfig_raw" {
  description = "Raw kubeconfig for kubectl"
  value       = base64encode(jsonencode({
    apiVersion = "v1"
    kind       = "Config"
    current-context = "aws_eks"
    clusters = [{
      name = module.eks.cluster_name
      cluster = {
        server                   = module.eks.cluster_endpoint
        certificate-authority-data = module.eks.cluster_certificate_authority_data
      }
    }]
    contexts = [{
      context = {
        cluster = module.eks.cluster_name
        user    = "aws_eks"
      }
      name = "aws_eks"
    }]
    users = [{
      name = "aws_eks"
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
        }
      }
    }]
  }))
  sensitive = true
}