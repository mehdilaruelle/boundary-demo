output "rds_endpoint" {
  value = aws_db_instance.target.endpoint
}

output "rds_username" {
  value = aws_db_instance.target.username
}

output "rds_dbname" {
  value = aws_db_instance.target.name
}

output "rds_password" {
  value     = random_password.db_master_pass.result
  sensitive = true
}
