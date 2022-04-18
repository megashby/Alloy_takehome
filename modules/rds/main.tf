
// would not actually recommend doing this in production environments
resource "random_password" "rds_password_new" {
  length           = 16
  special          = false
}

resource "aws_secretsmanager_secret" "db_master_secret_new" {
   name = "alloy-db-master-secret-2"
}

resource "aws_secretsmanager_secret_version" "db_master_secret_version_new" {
  secret_id = aws_secretsmanager_secret.db_master_secret_new.id
  secret_string = <<EOF
   {
   "username": "admin",
    "password": "${random_password.rds_password_new.result}"
   }
EOF
}

data "aws_secretsmanager_secret" "db_master_secret_new" {
  arn = aws_secretsmanager_secret.db_master_secret_new.arn
}

data "aws_secretsmanager_secret_version" "db_master_secret_creds_new" {
  secret_id = data.aws_secretsmanager_secret.db_master_secret_new.arn
}

locals {
  db_creds_string_new = jsondecode(data.aws_secretsmanager_secret_version.db_master_secret_creds_new.secret_string)
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"

  subnet_ids = var.db_subnets_id
}

resource "aws_db_instance" "rds_instance" { 
  identifier             = "alloy-rds-db"
  allocated_storage      = var.rds_storage
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  multi_az               = true
  name                   = "AlloyRdsDb"
  username              = local.db_creds_string_new.username
  password              = local.db_creds_string_new.password
  skip_final_snapshot   = true
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]
  enabled_cloudwatch_logs_exports = ["audit", "error"]
  storage_encrypted = true

}

  