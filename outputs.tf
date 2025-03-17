# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

# Output the public IP of the instance
output "instance_public_ip" {
  value       = aws_spot_instance_request.ec2_spot_request.public_ip
  description = "Public IP address of the GitHub runner instance"
}

output "subdomain_url" {
  value       = "https://${var.project_name}.${var.domain_name}"
  description = "Main URL for accessing the spot EC2 instance."
}
