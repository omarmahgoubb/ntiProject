output "jenkins_public_ip" { value = aws_instance.jenkins.public_ip }
output "eks_cluster_name"  { value = aws_eks_cluster.project_cluster.name }
output "eks_cluster_endpoint" { value = aws_eks_cluster.project_cluster.endpoint }
output "db_endpoint" { value = aws_db_instance.project_db.address }
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
output "ecr_backend_url"  { value = aws_ecr_repository.backend.repository_url }
