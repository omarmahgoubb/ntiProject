variable "aws_region" {
  default = "eu-west-1"
}
variable "eks_cluster_name" {
  description = "Name for the EKS cluster"
  default     = "project-cluster"
}
variable "my_ip_cidr" {
  description = "Your public IPv4 /32 to allow SSH/HTTP to Jenkins"
  type        = string
}
variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins EC2"
  type        = string
  default     = "t3.micro"   # change to t3.small if you prefer
}
