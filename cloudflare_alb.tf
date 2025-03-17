# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

# Cloudflare DNS record
resource "cloudflare_record" "alb" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.project_name}"
  content = aws_spot_instance_request.ec2_spot_request.public_ip
  type    = "A"
  ttl     = 300
  proxied = false
}

