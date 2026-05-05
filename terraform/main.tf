terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────
# VPC Module
# ─────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "ecom-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  map_public_ip_on_launch = true

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "ecom-vpc"
    Project = "ecommerce"
  }
}

# ─────────────────────────────
# KMS Key for EKS Encryption
# ─────────────────────────────
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name    = "eks-encryption-key"
    Project = "ecommerce"
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks-encryption"
  target_key_id = aws_kms_key.eks.key_id
}

# ─────────────────────────────
# Data source for availability zones
# ─────────────────────────────
data "aws_availability_zones" "available" {
  state = "available"
}

# ─────────────────────────────
# EKS Cluster
# ─────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "ecom-eks"
  cluster_version = "1.29"

  enable_cluster_creator_admin_permissions = true

  # ─────────────────────────────
  # API endpoint access
  # ─────────────────────────────
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Change to your IP range
  cluster_endpoint_private_access      = true

  # ─────────────────────────────
  # Logging
  # ─────────────────────────────
  create_cloudwatch_log_group = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # ─────────────────────────────
  # Encryption at rest
  # ─────────────────────────────
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_key.eks.arn
  }

  # ─────────────────────────────
  # Networking
  # ─────────────────────────────
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  # ─────────────────────────────
  # Node Group
  # ─────────────────────────────
  eks_managed_node_groups = {
    general = {
      desired_size   = 3
      min_size       = 2
      max_size       = 4

      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"

      tags = {
        NodeGroup = "general"
      }
    }
  }

  # ─────────────────────────────
  # Tags
  # ─────────────────────────────
  tags = {
    Project = "ecommerce"
  }

  depends_on = [module.vpc]
}