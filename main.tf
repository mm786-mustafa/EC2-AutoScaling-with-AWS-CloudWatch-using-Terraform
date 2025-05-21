data "aws_availability_zones" "available" {} # Fetching AZs

data "aws_secretsmanager_secret" "rds_secret" {
  name = "dev/mustafa/rds"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

module "vpc" {
  source = "./modules/vpc"
  environment = terraform.workspace
  vpc_name = var.vpc.name
  vpc_cidr = var.vpc.cidr
  igw_name = var.vpc.igw_name
  eip_name = var.vpc.eip_name
  ngw_name = var.vpc.ngw_name
  public_RT_name = var.vpc.public_RT_name
  private_RT_name = var.vpc.private_RT_name
  public_subnet_name = var.vpc.public_subnet_name
  private_subnet_name = var.vpc.private_subnet_name
  subnet_mask = var.vpc.subnet_mask
  sg_name = var.vpc.sg_name
}

module "rds" {
  source = "./modules/rds-instance"
  environment = terraform.workspace
  rds_instance_identifier = var.rds.identifier
  allocated_storage_value = var.rds.allocated_storage
  db_name = var.rds.db_name
  db_username = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  db_password = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]
  security_group_id = module.vpc.security_group_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "tg" {
  source = "./modules/target-group"
  environment = terraform.workspace
  target_group_name = var.tg.name
  vpc_id = module.vpc.vpc_id
}

module "lb" {
  source = "./modules/load-balancer"
  environment = terraform.workspace
  lb_name = var.lb.name
  security_group_id = module.vpc.security_group_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_group_arn = module.tg.arn
}

module "autoscaling" {
  source = "./modules/autoscaling"
  environment = terraform.workspace
  launch_template_name = var.asg.launch_template_name
  instance_type = var.asg.instance_type 
  image_id = var.asg.image_id
  key_name = var.asg.key_name
  security_group_id = module.vpc.security_group_id
  rds_db_name = module.rds.rds_db_name
  rds_username = module.rds.rds_username
  rds_password = module.rds.rds_password
  rds_endpoint = module.rds.rds_endpoint
  autoscaling_group_name = var.asg.asg_name
  # availability_zones = data.aws_availability_zones.available.names
  asg_desired_capacity_type = var.asg.desired_capacity_type
  asg_desired_capacity = var.asg.desired_capacity
  asg_max_size = var.asg.max_size
  asg_min_size = var.asg.min_size
  health_check_type = var.asg.health_check_type
  health_check_grace_period = var.asg.health_check_grace_period
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn = module.tg.arn
}