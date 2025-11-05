# Store DB creds in Secrets Manager (username fixed, password generated)
resource "aws_secretsmanager_secret" "db_secret" {
  name = "project-postgres-credentials"
}

# Generate a strong password
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "_%@!#-"   # avoid characters some clients dislike
}

resource "aws_secretsmanager_secret_version" "db_secret_v" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "masteruser"                      # NOT 'admin' (reserved)
    password = random_password.db_password.result
  })
}

# DB subnet group (use our two public subnets)
resource "aws_db_subnet_group" "project_db_subnets" {
  name       = "project-db-subnets"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  tags = { Name = "project-db-subnets" }
}

# Security group for DB (allow 5432 from your IP)
resource "aws_security_group" "db_sg" {
  name        = "project-db-sg"
  description = "Allow PostgreSQL from my IP"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL (publicly accessible)
resource "aws_db_instance" "project_db" {
  identifier               = "project-db"
  engine                   = "postgres"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20

  username                 = jsondecode(aws_secretsmanager_secret_version.db_secret_v.secret_string)["username"]
  password                 = jsondecode(aws_secretsmanager_secret_version.db_secret_v.secret_string)["password"]

  db_subnet_group_name     = aws_db_subnet_group.project_db_subnets.name
  vpc_security_group_ids   = [aws_security_group.db_sg.id]
  publicly_accessible      = true

  skip_final_snapshot      = true
  delete_automated_backups = true

  depends_on = [aws_db_subnet_group.project_db_subnets]
}
