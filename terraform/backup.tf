resource "aws_backup_vault" "vault" {
  name = "${var.project_name}-backup-vault"
}

resource "aws_backup_plan" "plan" {
  name = "${var.project_name}-daily-plan"
  rule {
    rule_name         = "daily-snapshots"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 21 * * ? *)" # ~11PM Cairo
    lifecycle { delete_after = 14 }
  }
}

resource "aws_backup_selection" "jenkins" {
  name         = "jenkins-selection"
  iam_role_arn = aws_iam_role.backup.arn
  resources    = [aws_instance.jenkins.arn]
  plan_id      = aws_backup_plan.plan.id
}
