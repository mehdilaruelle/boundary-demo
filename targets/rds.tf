resource "random_password" "db_master_pass" {
  length  = 30
  special = false
}

resource "aws_db_instance" "target" {
  allocated_storage   = var.db_storage
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "11.8"
  instance_class      = var.db_instance_class
  name                = var.db_name
  username            = var.db_username
  password            = random_password.db_master_pass.result
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.target.name
}

resource "aws_security_group" "db" {
  vpc_id = data.terraform_remote_state.boundary.outputs.vpc_id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_db_subnet_group" "target" {
  name       = local.tags["Name"]
  subnet_ids = data.terraform_remote_state.boundary.outputs.subnets_private
}
