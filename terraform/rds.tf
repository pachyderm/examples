resource "aws_db_subnet_group" "pachaform-db-subnet-group" {
  name = "${var.project_name}-db-subnet-group"
  description = "Pachyderm DB Subnet Group"
  subnet_ids = [
    aws_subnet.pachaform_public_subnet_1.id,
    aws_subnet.pachaform_public_subnet_2.id
  ]
}

resource "aws_db_instance" "pachaform-postgres" {
  identifier      = "${var.project_name}-postgres"
  allocated_storage      = var.db_storage
  max_allocated_storage  = var.db_max_storage
  engine                 = "postgres"
  engine_version         = var.db_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_name                = "pachyderm"
  iops                   = var.db_iops
  db_subnet_group_name   = aws_db_subnet_group.pachaform-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.pachaform_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
  apply_immediately      = true

  depends_on = [
    aws_db_subnet_group.pachaform-db-subnet-group,
    aws_internet_gateway.pachaform_internet_gateway,
    aws_nat_gateway.pachaform_nat_gateway,
  ]
}

resource "postgresql_database" "dex" {
  name = "dex"

  depends_on = [
    aws_db_instance.pachaform-postgres,
    aws_nat_gateway.pachaform_nat_gateway,
  ]
}

resource "postgresql_grant" "full-crud-dex" {
  database    = "dex"
  role        = "public"
  object_type = "database"
  objects     = []
  privileges  = ["ALL"]

  depends_on = [
    postgresql_database.dex
  ]
  lifecycle {
    ignore_changes = all
  }
}

resource "postgresql_grant" "full-crud-pachyderm" {
  database    = "pachyderm"
  role        = "public"
  object_type = "database"
  objects     = []
  privileges  = ["ALL"]

  depends_on = [
    aws_db_instance.pachaform-postgres,
    aws_nat_gateway.pachaform_nat_gateway,
  ]
  lifecycle {
    ignore_changes = all
  }
}