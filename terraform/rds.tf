resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = module.vpc.vpc_id
  tags = { Project = var.project_name }
}

resource "aws_security_group_rule" "rds_ingress_pg" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-rds-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "this" {
  identifier              = "${var.project_name}-rds"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class    # db.t3.small
  allocated_storage       = var.db_allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  skip_final_snapshot     = true
  storage_encrypted       = true
  deletion_protection     = false
  apply_immediately       = true
  backup_retention_period = 7
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}/rds/postgres"
  tags = { Project = var.project_name }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username,
    password = var.db_password,
    engine   = var.db_engine,
    host     = aws_db_instance.this.address,
    port     = 5432,
    dbname   = var.db_name
  })
}

output "rds_endpoint"   { value = aws_db_instance.this.address }
output "rds_secret_arn" { value = aws_secretsmanager_secret.db.arn }
