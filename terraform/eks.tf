# Security group for EKS cluster endpoint
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Allow EKS cluster communication"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EKS Cluster
resource "aws_eks_cluster" "project_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids          = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_group_ids  = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access = true
  }
}

# EKS Managed Node Group
resource "aws_eks_node_group" "project_nodes" {
  cluster_name    = aws_eks_cluster.project_cluster.name
  node_group_name = "${var.eks_cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  disk_size      = 20

  tags = {
    Name = "${var.eks_cluster_name}-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_registry_policy
  ]
}

