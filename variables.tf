# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

variable "aws_region" {
  description = "The aws region for the ec2 spot instance."
  type        = string
}

variable "aws_profile" {
  description = "The CLI aws profile on the local machine."
  type        = string
}

variable "project_name" {
  description = "The name of the project i.e. myproject"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment i.e. staging, dev"
  type        = string
  default     = "staging"
}

variable "max_spot_price" {
  description = "Maximum spot price we are ready to pay per hour in USD."
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type. i.e. t2.large"
  type        = string
}

variable "ami_id" {
  description = "ami id to be used for the ec2 spot instance. The project has been tested with the 'Amazon Linux 2023 AMI 2023.6.20250218.2 x86_64 HVM kernel-6.1'"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository URL. i.e. https://github.com/myuser/myproject"
  type        = string
}

variable "github_token" {
  description = "GitHub token for runner registration. Get it from https://github.com/myuser/myproject/settings/actions/runners/new"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the key pair in AWS"
  type        = string
}

variable "private_key_path" {
  description = "The local FS path to the pem file downloaded while creating the key_name in AWS."
  type        = string
}
