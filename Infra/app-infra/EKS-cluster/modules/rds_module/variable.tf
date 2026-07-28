variable "project_name" {
  type    = string
  default = "rds-prod"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "db_name" {
  type = string
}

variable "db_user_username" {
  type = string
  # default = "admin"
}


variable "db_password" {
  description = "RDS master pasword"
  type        = string
  sensitive   = true # not provide this value in tfvars , take it from terminal
}


variable "vpc_id" {
  type = string
}
# variable "private_subnet_1_id" {
#   type = string
# }
# variable "private_subnet_2_id" {
#   type = string
# }

variable "NM_private_subnets_ids" {
  type = list(string)
}