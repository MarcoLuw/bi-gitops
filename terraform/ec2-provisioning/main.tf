# Remember to set the AWS credentials in your environment variables or AWS config file.
# --- export AWS_ACCESS_KEY_ID=
# --- export AWS_SECRET_ACCESS_KEY=

provider "aws" { # "aws" -> get from required_providers in terraform.tf
  region = var.region
}

# Data sources
# Use data blocks to query your cloud provider for information about other resources.
# This data source fetches data about the latest AWS AMI that matches the filter -> no need to hardcode the AMI ID.
# Fact: data source is not an actual resource -> it does not create or manage resources, it only retrieves information.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # Official Amazon account for AL2023

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023 naming
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Resources
# resource block defines components of your infrastructure
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "tf_web_sg" {
  name        = "tf_web_sg"
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tf_web" {
  #   ami = "ami-0dd241d9f14584d00" # Amazon linux 2023 in ap-southeast-2 region
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  security_groups             = [aws_security_group.tf_web_sg.name]
  associate_public_ip_address = true

  tags = {
    Name        = "tf_web_instance"
    Environment = "Terraform"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ../../ansible/inventory/hosts.ini"
  }
}