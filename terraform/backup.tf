# Backup vault
resource "aws_backup_vault" "jenkins_vault" {
  name = "jenkins-backup-vault"
}

# Daily backup plan @ 00:00 UTC, keep 7 days
resource "aws_backup_plan" "jenkins_plan" {
  name = "jenkins-backup-plan"
  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.jenkins_vault.name
    schedule          = "cron(0 0 * * ? *)"
    lifecycle { delete_after = 7 }
  }
}

# Protect the Jenkins EC2 instance
resource "aws_backup_selection" "jenkins_selection" {
  name         = "jenkins-selection"
  plan_id      = aws_backup_plan.jenkins_plan.id
  iam_role_arn = aws_iam_role.backup_role.arn
  resources    = [aws_instance.jenkins.arn]
}
