module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.eks_version

  # PUBLIC endpoint enabled so you can reach it from home
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = { ami_type = "AL2_x86_64" }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types     # ["t3.small"]
      min_size       = var.node_min_size           # 2
      desired_size   = var.node_desired_size       # 2
      max_size       = var.node_max_size           # 4
      subnet_ids     = module.vpc.private_subnets
    }
  }

  tags = { Project = var.project_name }
}

output "cluster_name"     { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
