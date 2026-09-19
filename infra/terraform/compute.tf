data "aws_ssm_parameter" "al2023_arm64_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "server" {
  ami                         = data.aws_ssm_parameter.al2023_arm64_ami.value
  instance_type               = "t4g.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.server.id]
  iam_instance_profile        = aws_iam_instance_profile.server.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user

    if [ ! -f /swapfile ]; then
      fallocate -l 1G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi

    mkdir -p /opt/gymbro
    chown ec2-user:ec2-user /opt/gymbro
  EOF

  depends_on = [
    aws_iam_role_policy_attachment.ssm
  ]

  tags = {
    Name = "gymbro-server"
  }
}

resource "aws_eip" "server" {
  domain   = "vpc"
  instance = aws_instance.server.id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "gymbro-server-ip"
  }
}
