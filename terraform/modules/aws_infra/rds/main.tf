terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.16.0"
    }

  }
}

provider "postgresql" {
  scheme    = "awspostgres"
  host      = aws_db_instance.postgres.address
  username  = aws_db_instance.postgres.username
  port      = aws_db_instance.postgres.port
  password  = aws_db_instance.postgres.password
  superuser = false

  expected_version = aws_db_instance.postgres.engine_version
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Pachyderm DB Subnet Group"
  subnet_ids = var.public_subnet_ids
  tags = {
    Owner = var.admin_user
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres"
  allocated_storage      = var.db_storage
  max_allocated_storage  = var.db_max_storage
  engine                 = "postgres"
  engine_version         = var.db_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_name                = "pachyderm"
  iops                   = var.db_iops
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.sg_id]
  skip_final_snapshot    = true
  publicly_accessible    = true
  apply_immediately      = true

  tags = {
    Owner = var.admin_user
  }

  depends_on = [
    var.nat_gateway_id,
    var.rta_id_list
  ]
}

resource "postgresql_database" "dex" {
  name = "dex"

  depends_on = [
    aws_db_instance.postgres,
  ]
}

resource "postgresql_grant" "full_crud_dex" {
  database    = "dex"
  role        = "public"
  object_type = "database"
  objects     = []
  privileges  = ["ALL"]

  depends_on = [
    postgresql_database.dex,
  ]
  lifecycle {
    ignore_changes = [privileges]
  }
}

resource "postgresql_grant" "full_crud_pachyderm" {
  database    = "pachyderm"
  role        = "public"
  object_type = "database"
  objects     = []
  privileges  = ["ALL"]

  depends_on = [
    aws_db_instance.postgres,
  ]
  lifecycle {
    ignore_changes = [privileges]
  }
}
