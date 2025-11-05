resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{
      Effect="Allow", Principal={Service="ec2.amazonaws.com"}, Action="sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

# Backup role
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-backup-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{
      Effect="Allow", Principal={Service="backup.amazonaws.com"}, Action="sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "backup_attach" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
