# This Terraform configuration is part of the project Spot-EC2-Github-runner-Docker-compose-Cloudflare-DNS.
# Please refer to the README.md and LICENSE file for disclaimer and licensing information.

# Launch template for the spot instance
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "github-runner-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "github-runner"
    }
  }
}

# Create spot instance request
resource "aws_spot_instance_request" "ec2_spot_request" {
  spot_price                     = var.max_spot_price
  wait_for_fulfillment           = true
  spot_type                      = "persistent"
  instance_interruption_behavior = "terminate"
  instance_type                  = var.instance_type
  subnet_id                      = aws_subnet.main.id
  ami                            = var.ami_id
  key_name                       = var.key_name
  security_groups                = [aws_security_group.web.id]

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Install necessary packages
    yum update -y

    # Install CloudWatch Agent
    yum install -y amazon-cloudwatch-agent
    yum install -y ec2-instance-connect

    # Configure the CloudWatch Agent
    tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOL
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "${aws_cloudwatch_log_group.github_runner_logs.name}",
                "log_stream_name": "{instance_id}",
                "timestamp_format": "%b %d %H:%M:%S"
              }
            ]
          }
        }
      }
    }
    EOL

    # Start the CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s


    # Install Docker
    dnf update -y
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    mkdir -p /usr/local/lib/docker/cli-plugins
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    #Needed by the config script of GitHub runner
    yum install libicu -y

    # Create the github user
    adduser github
    usermod -aG docker github

  EOF
  )

  tags = {
    Name        = "github-runner-spot"
    Environment = "${var.environment_name}"
  }
}

# Data source to get the instance ID from the spot instance request
data "aws_instance" "ec2_instance_data" {
  instance_id = aws_spot_instance_request.ec2_spot_request.spot_instance_id
}

resource "null_resource" "wait_ec2_instance_running" {
  provisioner "local-exec" {
    command = <<-EOT
      AWS_PROFILE=${var.aws_profile}
      AWS_REGION=${var.aws_region}
      INSTANCE_ID="${data.aws_instance.ec2_instance_data.id}"
      while true; do
        state=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].State.Name" --output text --profile $AWS_PROFILE --region $AWS_REGION)
        status=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query "InstanceStatuses[*].InstanceStatus.Status" --output text --profile $AWS_PROFILE --region $AWS_REGION)
        echo "    state:$state ; status:$status"
        if [ "$state" = "running" ] && [ "$status" = "ok" ]; then
          echo "Instance is running and has passed all status checks."
          break
        fi

        echo "Waiting for instance to be in 'running' state and pass status checks..."
        sleep 10
      done
    EOT
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${var.private_key_path}")
    host        = aws_spot_instance_request.ec2_spot_request.public_ip
  }
}

resource "null_resource" "config_github_runner" {
  provisioner "remote-exec" {
    inline = [
      "sudo -u github bash -c 'cd /home/github && wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh >> /home/github/config_github_runner.log 2>&1'",
      "sudo -u github bash -c 'cd /home/github && chmod +x ./dotnet-install.sh >> /home/github/config_github_runner.log 2>&1'",
      "sudo -u github bash -c 'export PATH=$PATH:/home/github/.dotnet && cd /home/github && mkdir actions-runner && cd actions-runner >> /home/github/config_github_runner.log 2>&1'",
      "sudo -u github bash -c 'cd /home/github/actions-runner && curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz >> /home/github/config_github_runner.log 2>&1'",
      "sudo -u github bash -c 'cd /home/github/actions-runner && tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz >> /home/github/config_github_runner.log 2>&1'",
      "sudo -u github bash -c 'cd /home/github/actions-runner && ./config.sh --unattended  --labels ${var.environment_name} --url ${var.github_repo_url} --token ${var.github_token} >> /home/github/config_github_runner.log 2>&1'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.private_key_path}")
      host        = aws_spot_instance_request.ec2_spot_request.public_ip
    }
  }

  depends_on = [null_resource.wait_ec2_instance_running]
}

resource "null_resource" "start_github_runner_as_service" {
  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'cd /home/github/actions-runner && ./svc.sh install github >> /start_github_runner_as_service.log 2>&1'",
      "sudo bash -c 'cd /home/github/actions-runner && ./svc.sh start >> /start_github_runner_as_service.log 2>&1'",
      "sudo bash -c 'cd /home/github/actions-runner && ./svc.sh status > ./github_runner_status.txt >> /start_github_runner_as_service.log 2>&1'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.private_key_path}")
      host        = aws_spot_instance_request.ec2_spot_request.public_ip
    }
  }

  depends_on = [null_resource.config_github_runner]
}
