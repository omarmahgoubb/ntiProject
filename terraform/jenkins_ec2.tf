data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  # Try multiple Ubuntu LTS name patterns (24.04 & 22.04) to avoid "no results"
  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*",
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*",
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }

  # Extra filters keep results sane
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name   = "${var.project_name}-jenkins-sg"
  vpc_id = module.vpc.vpc_id
  tags   = { Project = var.project_name }
}

resource "aws_security_group_rule" "jenkins_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_blocks       = var.allowed_ingress_cidrs
}

resource "aws_security_group_rule" "jenkins_ingress_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_blocks       = var.allowed_ingress_cidrs
}

resource "aws_security_group_rule" "jenkins_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_key_pair" "jenkins" {
  key_name   = var.jenkins_key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_instance_type   # t3.small
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.jenkins.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name

  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-jenkins"
    Project = var.project_name
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
