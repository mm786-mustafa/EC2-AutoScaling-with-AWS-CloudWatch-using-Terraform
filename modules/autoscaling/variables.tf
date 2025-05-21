variable "environment" {
  description = "Environment in which infrastructure is being created."
  type = string
}

# ********* Launch Template *********
variable "launch_template_name" {
  description = "Name of EC2 Instance"
  type = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance."
  type = string
}

variable "image_id" {
  description = "Also known as image id."
  type = string
}

variable "key_name" {
  description = "Key for remote access."
  type = string
}

variable "security_group_id" {
  description = "Id of security group"
  type = string
}

variable "rds_db_name" {
  description = "Name of databse"
  type = string
}

variable "rds_username" {
  description = "Name of user"
  type = string
}

variable "rds_password" {
  description = "Password of database"
  type = string
}

variable "rds_endpoint" {
  description = "Endpoint"
  type = string
}

# ********* Autoscaling Group *********
variable "autoscaling_group_name" {
  description = "Name of Autoscaling Group"
  type = string
}

# variable "availability_zones" {
#   description = "List of availability zones"
#   type = list(string)
# }

variable "asg_desired_capacity_type" {
  description = "Type of desired capacity for the autoscaling group."
  type = string
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the autoscaling group."
  type = number
}

variable "asg_max_size" {
  description = "Maximum size for the autoscaling group."
  type = number
}

variable "asg_min_size" {
  description = "Minimum size for the autoscaling group."
  type = number
}

variable "health_check_type" {
  description = "Type of health check for the autoscaling group."
  type = string
}

variable "health_check_grace_period" {
  description = "Grace period for health checks."
  type = number
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type = list(string) 
}

variable "target_group_arn" {
  description = "List of target group ARNs."
  type = string
}

# variable "asg_cooldown" {
#   description = "Cooldown period for the autoscaling group."
#   type = number
# }