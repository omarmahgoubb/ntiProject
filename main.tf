provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "project_key" {
  key_name   = "nti-project-key"
  public_key = file("~/.ssh/nti-project-key.pub")
}

