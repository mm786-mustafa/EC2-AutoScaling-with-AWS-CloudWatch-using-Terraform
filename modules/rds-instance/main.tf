data "aws_region" "current" {} # Fetching Current Region

# *** RDS Database ***
resource "aws_db_instance" "my_rds_database" {
  allocated_storage = var.allocated_storage_value
  identifier = "${var.rds_instance_identifier}-${var.environment}"
  db_name = var.db_name
  engine = "mysql"
  engine_version = "8.0.33"
  storage_type = "gp3"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id
  vpc_security_group_ids = [ var.security_group_id ]
  skip_final_snapshot = true
  tags = {
    Name = "${var.environment}-${var.rds_instance_identifier}-${data.aws_region.current.name}"
  }
}

# *** DB Subnet Group for RDS ***
resource "aws_db_subnet_group" "my_db_subnet_group" {
  description = "Subnet group for RDS"
  subnet_ids = var.private_subnet_ids
}