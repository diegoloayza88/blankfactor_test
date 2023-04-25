output "rds_endpoint" {
  description = "The RDS postgres endpoint"
  value       = aws_db_instance.test_bf_instance.endpoint
}