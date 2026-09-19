output "server_public_ip" {
  description = "Public IP address for GymBro server"
  value       = aws_eip.server.public_ip
}

output "server_instance_id" {
  description = "EC2 instance ID for Systems Manager"
  value       = aws_instance.server.id
}
