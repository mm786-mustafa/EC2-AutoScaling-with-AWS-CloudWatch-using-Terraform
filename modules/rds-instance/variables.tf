variable "environment" {
  description = "Environment in which infrastructure is being created."
  type = string
}

variable "rds_instance_identifier" {
  description = "Instance identifier"
  type = string
}

variable "allocated_storage_value" {
  description = "value of allocated storage capacity"
  type = number
}

variable "db_name" {
  description = "Database name"
  type = string
}

variable "db_username" {
  description = "Database username"
  type = string
}

variable "db_password" {
  description = "Database password"
  type = string
}

variable "security_group_id" {
  description = "Id of sg"
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet ids"
  type = list(string)
}