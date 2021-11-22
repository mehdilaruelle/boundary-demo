variable "region" {
  default = "eu-west-1"
}

variable "owner" {
  description = "The owner of the application or the owner of the deployed stack."
  default     = "Terraform"
}

variable "env" {
  description = "Environment variable for the application."
  default     = "dev"
}

variable "app" {
  description = "Your application name."
  default     = "boundary"
}

variable "instance_type" {
  description = "The EC2 instance size and type."
  default     = "t3.small"
}

variable "vpc_cidr" {
  description = "The CIDR to use for the VPC."
  default     = "10.0.0.0/16"
}

#Database for Boundary
variable "db_storage" {
  description = "The database storage in GB."
  default     = 20
}

variable "db_instance_class" {
  description = "The database instance size & type."
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The database name."
  default     = "boundary"
}

variable "db_username" {
  description = "The admin username for the database."
  default     = "boundary"
}
