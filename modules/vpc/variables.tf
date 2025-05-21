variable "environment" {
  description = "Development environment"
  type = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type = string
}

variable "vpc_cidr" {
  description = "Cidr block of VPC"
  type = string
}

variable "igw_name" {
  description = "Name of internet gateway"
  type = string
}

variable "eip_name" {
  description = "Name of elastic ip address"
  type = string
}

variable "ngw_name" {
  description = "Name of nat gateway"
  type = string
}

variable "public_RT_name" {
  description = "Name of public route table"
  type = string
}

variable "private_RT_name" {
  description = "Name of private route table"
  type = string
}
variable "subnet_mask" {
  description = "Subnet mask of subnets"
  type = string
}

variable "public_subnet_name" {
  description = "Name of public subnet"
  type = string
}

variable "private_subnet_name" {
  description = "Name of private subnet"
  type = string
}

variable "sg_name" {
  description = "Name of security group"
  type = string
}