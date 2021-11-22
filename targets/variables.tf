variable "region" {
  default = "eu-west-1"
}

variable "app" {
  description = "The application name."
  default     = "boundary-target"
}

variable "owner" {
  description = "The owner of the application or the owner of the deployed stack."
  default     = "Terraform"
}

#Database target for connection
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
  default     = "app"
}

variable "db_username" {
  description = "The admin username for the database."
  default     = "app"
}
