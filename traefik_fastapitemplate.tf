# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

resource "null_resource" "copy_traefik_docker_compose" {
  count = var.traefik_docker_compose_path != "" ? 1 : 0
  provisioner "file" {
    source      = var.traefik_docker_compose_path
    destination = "/home/ec2-user/docker-compose.traefik.yml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.private_key_path}")
      host        = aws_spot_instance_request.ec2_spot_request.public_ip
    }
  }
  depends_on = [null_resource.start_github_runner_as_service]
}

resource "null_resource" "traefik_docker_provisioner" {
  count = var.traefik_docker_compose_path != "" ? 1 : 0
  provisioner "remote-exec" {
    inline = [
      "sudo  cp /home/ec2-user/docker-compose.traefik.yml /home/github/actions-runner/docker-compose.traefik.yml >> ~/traefik_docker_provisioner.log 2>&1",
      "sudo  chown github:github /home/github/actions-runner/docker-compose.traefik.yml >> ~/traefik_docker_provisioner.log 2>&1",
      "sudo -u github bash -c 'cd /home/github/actions-runner && docker network create traefik-public >> ~/traefik_docker_provisioner.log 2>&1'",
      "sudo -u github bash -c 'export USERNAME=${var.traefik_user_env} PASSWORD=${var.traefik_password_env} HASHED_PASSWORD=${var.traefik_hashed_password_env} EMAIL=${var.traefik_email_env} DOMAIN=${local.sub_domain} && env >> ~/env_check.txt && cd /home/github/actions-runner && docker compose -f docker-compose.traefik.yml up -d >> ~/traefik_docker_provisioner.log 2>&1'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.private_key_path}")
      host        = aws_spot_instance_request.ec2_spot_request.public_ip
    }
  }

  depends_on = [null_resource.copy_traefik_docker_compose]
}
