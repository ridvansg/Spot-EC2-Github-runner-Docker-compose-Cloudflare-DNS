# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

variable "traefik_docker_compose_path" {
  description = "Path to traefik-docker-compose.yml"
  type        = string
  default     = ""
}

variable "traefik_user_env" {
  description = "USER env variable for traefik-docker-compose.yml"
  type        = string
  default     = ""
}

variable "traefik_password_env" {
  description = "PASSWORD env variable for traefik-docker-compose.yml"
  type        = string
  default     = ""
}

variable "traefik_hashed_password_env" {
  description = "HASHED_PASSWORD env variable for traefik-docker-compose.yml"
  type        = string
  default     = ""
}

variable "traefik_email_env" {
  description = "EMAIL env variable for traefik-docker-compose.yml"
  type        = string
  default     = ""
}

