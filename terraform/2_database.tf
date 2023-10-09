resource "random_string" "db_password" {
  length  = 32
  upper   = true
  numeric  = true
  special = false
}

resource "aws_security_group" "db_sg" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "postgres_sg"
  description = "Allow all inbound for Postgres"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = module.dynamic_subnets.public_subnet_ids

  tags = {
    Name = "Postgres DB subnet group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  identifier             = "postgres-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "alejandro"
  password               = "${random_string.db_password.result}"
}
