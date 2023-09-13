output "rds_endpoint" {
  value = aws_db_instance.devops_rds.endpoint
}

output "ec2_public_ip" {
  value = aws_instance.devops_ec2.public_ip
}
