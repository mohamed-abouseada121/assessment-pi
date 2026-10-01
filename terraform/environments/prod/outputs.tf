output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "ec2_public_dns" {
  value = module.ec2.public_dns
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_address" {
  value = module.rds.address
}

output "backend_ecr_url" {
  value = var.enable_ecr ? module.ecr[0].backend_repository_url : ""
}

output "frontend_ecr_url" {
  value = var.enable_ecr ? module.ecr[0].frontend_repository_url : ""
}

output "cloudwatch_log_group" {
  value = module.monitoring.log_group_name
}

output "application_url" {
  value = "http://${module.ec2.public_ip}"
}
