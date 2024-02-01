provider "aws" {
  region = "eu-central-1"
}

variable "subdomain" {
  description = "The subdomain for the instance"
  type        = string
}

# The network stuff already exists, so we can comment it out
# We will use the existing VPC, subnet and security group

# resource "aws_vpc" "demo_vpc" {
#   cidr_block = "10.0.0.0/16" # Replace with your desired CIDR block

#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name = "jirka-VPC"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.demo_vpc.id
# }

# resource "aws_route_table" "route_table" {
#   vpc_id = aws_vpc.demo_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }
#   tags = {
#     Name = "jirka-RT"
#   }
# }

# resource "aws_subnet" "my_subnet" {
#   vpc_id            = aws_vpc.demo_vpc.id
#   cidr_block        = "10.0.1.0/24" # Replace with your desired CIDR block
#   availability_zone = "eu-central-1a"
#   tags = {
#     Name = "jirka-subnet"
#   }
# }

# resource "aws_route_table_association" "route_table_asso" {
#   subnet_id      = aws_subnet.my_subnet.id
#   route_table_id = aws_route_table.route_table.id
# }

# resource "aws_security_group" "instance_sg" {
#   name        = "jirka_webserver_sg2"
#   description = "Allow inbound SSH and HTTP traffic"
#   vpc_id      = aws_vpc.demo_vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "jirka-web-traffic"
#   }
# }

data "aws_subnet" "existing" {
  filter {
    name   = "tag:Name"
    values = ["jirka-subnet"]
  }
}

data "aws_security_group" "existing" {
  filter {
    name   = "tag:Name"
    values = ["jirka-web-traffic"]
  }
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "jirka-cluster-${var.subdomain}"

  tags = {
    Name = "jirka-cluster"
    Namespace = "cio"
    Subdomain = var.subdomain
  }
}

resource "aws_instance" "webserver" {
  ami               = data.aws_ami.ecs_optimized.id
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  associate_public_ip_address = true
  vpc_security_group_ids = [data.aws_security_group.existing.id]
  subnet_id              = data.aws_subnet.existing.id

  tags = {
    Name = "jirka-web-server-instance-${var.subdomain}"
    Namespace = "cio"
    Subdomain = var.subdomain
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" >> /etc/ecs/ecs.config
    sudo yum update -y
    sudo yum install httpd -y
    sudo yum install mod_ssl -y
    sudo systemctl start httpd
    sudo bash -c 'echo Congratulations! This is your Webserver Installation. ID: ${var.subdomain} HOSTNAME: $(hostname) > /var/www/html/index.html'
  EOF
}

# eg: 18.192.107.229
output "webserver_url" {
  value = aws_instance.webserver.public_ip
}

# eg: ec2-18-192-107-229.eu-central-1.compute.amazonaws.com
output "webserver_dns" {
  value = aws_instance.webserver.public_dns
}
