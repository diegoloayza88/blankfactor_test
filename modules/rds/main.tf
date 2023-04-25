################################################################################
# RDS instance and related resources
################################################################################
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = "interview27-rds-password"
}


resource "aws_db_instance" "test_bf_instance" {
  instance_class         = var.instance_class
  identifier             = "${var.rds_name_prefix}-rds"
  engine                 = var.engine
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  username               = var.username
  password               = data.aws_secretsmanager_secret_version.rds_password.secret_string
  name                   = var.db_name
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.test_bf_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]


  tags = merge(
    { "Name" = "${upper(var.rds_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_db_subnet_group" "test_bf_subnet_group" {
  subnet_ids = var.subnet_ids
  name       = "${var.rds_name_prefix}-rds-sn"
  tags = merge(
    { "Name" = "${upper(var.rds_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.rds_name_prefix}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.autoscaling_group_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${upper(var.rds_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}