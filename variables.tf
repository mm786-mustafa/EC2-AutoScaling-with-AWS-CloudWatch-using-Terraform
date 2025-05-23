variable "environment" {
  description = "Environment in which infrastructure is being created."
  type = string
}

variable "AWS" {
  description = "AWS Configuration"
  type = object({
    region = string
  })
}

variable "vpcs" {
  description = "Vpc Configuration"
  type = list(object({
    name = string
    cidr = string
    igw_name = string
    eip_name = string
    ngw_name = string
    public_RT_name = string
    private_RT_name = string
    public_subnet_name = string
    private_subnet_name = string
    subnet_mask = string
    sg_name = string
  }))
}

variable "rds" {
  description = "RDS Configuration"
  type = object({
    identifier = string
    allocated_storage = number
    db_name = string
  })
}

variable "tg" {
  description = "Target Group Configuration"
  type = object({
    name = string
  })
}

variable "lb" {
  description = "Load Balancer Configuration"
  type = object({
    name = string
  })
}

variable "asg" {
  description = "Autoscaling Configuration"
  type = object({
    launch_template_name = string
    instance_type = string
    image_id = string
    key_name = string
    asg_name = string
    desired_capacity_type = string
    desired_capacity = number
    max_size = number
    min_size = number
    health_check_type = string
    health_check_grace_period = number
  })
}