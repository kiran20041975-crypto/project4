# ─────────────────────────────
# Data sources for cluster access (only created after cluster exists)
# ─────────────────────────────
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

locals {
  cluster_endpoint             = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate       = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  cluster_auth_token           = data.aws_eks_cluster_auth.this.token
}

# Note: Node groups are now managed by the EKS module in main.tf
# The module creates managed node groups, which is the recommended approach