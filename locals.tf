# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

locals {
  sub_domain = "${var.project_name}.${var.domain_name}" # i.e. would result in myproject.mydomain.com
}
