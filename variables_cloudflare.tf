# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

variable "domain_name" {
  description = "The domain name. i.e. mydomain.com"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token with the following permissions: All zones - Zone:Read, Page Rules:Edit, DNS:Edit. Use 'Client IP Address Filtering' on the token for limited IP addresses."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for your domain"
  type        = string
  default     = "e168be3264cf0a21accbc29bc652d189"
}

