resource "aws_db_subnet_group" "pachaform_db_subnet_group" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Pachyderm DB Subnet Group"
  subnet_ids = [
    aws_subnet.pachaform_public_subnet_1.id,
    aws_subnet.pachaform_public_subnet_2.id,
  ]
  depends_on = [
    aws_route_table_association.pachaform_public_rta_1,
    aws_route_table_association.pachaform_public_rta_2,
  ]
}

resource "aws_db_instance" "pachaform_postgres" {
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
  db_subnet_group_name   = aws_db_subnet_group.pachaform_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.pachaform_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
  apply_immediately      = true

  depends_on = [
    aws_db_subnet_group.pachaform_db_subnet_group,
    aws_internet_gateway.pachaform_internet_gateway,
    aws_security_group.pachaform_sg,
    aws_nat_gateway.pachaform_nat_gateway,
    aws_route.pachaform_private_route,
    aws_route.pachaform_public_route,
  ]
}

resource "postgresql_database" "dex" {
  name = "dex"

  depends_on = [
    aws_db_instance.pachaform_postgres,
    aws_nat_gateway.pachaform_nat_gateway,
    aws_security_group.pachaform_sg,
    aws_route.pachaform_public_route,
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
    aws_security_group.pachaform_sg,
  ]
  lifecycle {
    ignore_changes = all
  }
}

resource "postgresql_grant" "full_crud_pachyderm" {
  database    = "pachyderm"
  role        = "public"
  object_type = "database"
  objects     = []
  privileges  = ["ALL"]

  depends_on = [
    aws_db_instance.pachaform_postgres,
    aws_nat_gateway.pachaform_nat_gateway,
    aws_security_group.pachaform_sg,
    aws_route.pachaform_public_route,
  ]
  lifecycle {
    ignore_changes = all
  }
}
