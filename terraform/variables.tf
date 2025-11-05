variable "project_name" {
  type = string
}
variable "aws_region" {
  type = string
}

# VPC
variable "vpc_cidr" {
  type = string
}
variable "azs" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}

# ECR
variable "project_frontend_repo_name" {
  type    = string
  default = "project-frontend"
}
variable "project_backend_repo_name" {
  type    = string
  default = "project-backend"
}

# S3 for ALB logs
variable "alb_logs_bucket_name" {
  type = string
}
variable "alb_logs_prefix" {
  type = string
}

# EKS
variable "eks_version" {
  type = string
}
variable "node_instance_types" {
  type = list(string)
}
variable "node_min_size" {
  type = number
}
variable "node_desired_size" {
  type = number
}
variable "node_max_size" {
  type = number
}

# Jenkins EC2
variable "jenkins_instance_type" {
  type = string
}
variable "jenkins_key_name" {
  type = string
}
variable "public_key_path" {
  type = string
}
variable "allowed_ingress_cidrs" {
  type = list(string)
}

# RDS
variable "db_engine" {
  type = string
}
variable "db_engine_version" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_instance_class" {
  type = string
}
variable "db_allocated_storage" {
  type = number
}
