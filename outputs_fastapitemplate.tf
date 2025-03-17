# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

output "api_url_fastapitemplate" {
  value       = "https://api.${var.environment_name}.${var.project_name}.${var.domain_name}/docs  username/password from github secrets FIRST_SUPERUSER/FIRST_SUPERUSER_PASSWORD"
  description = "Public URL for the Open API docs"
}

output "frontend_url_fastapitemplate" {
  value       = "https://dashboard.${var.environment_name}.${var.domain_name}  username/password from github secrets FIRST_SUPERUSER/FIRST_SUPERUSER_PASSWORD"
  description = "Public URL for the React frontend"
}

output "adminer_url_fastapitemplate" {
  value       = "https://adminer.${var.environment_name}.${var.domain_name}  username/password from github secrets FIRST_SUPERUSER/FIRST_SUPERUSER_PASSWORD"
  description = "Public URL for the adminer"
}
