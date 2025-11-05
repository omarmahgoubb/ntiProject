resource "aws_ecr_repository" "frontend" {
  name                 = var.project_frontend_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  force_delete         = true
  tags = { Project = var.project_name }
}
resource "aws_ecr_repository" "backend" {
  name                 = var.project_backend_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  force_delete         = true
  tags = { Project = var.project_name }
}
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
output "ecr_backend_url"  { value = aws_ecr_repository.backend.repository_url }
