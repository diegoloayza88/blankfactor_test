output "rds_endpoint" {
  description = "The RDS postgres endpoint"
  value       = module.rds_db.rds_endpoint
}