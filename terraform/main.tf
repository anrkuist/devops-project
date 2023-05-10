data "external" "whatismyip" {
  program = ["/bin/bash" , "./get-my-ip.sh"]
}

provider "aws" {
  profile = "terraform"
  region = var.aws_region
}

resource "aws_vpc" "docker-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name : "$;{var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "docker-subnet-1" {
  vpc_id            = aws_vpc.docker-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

output "dev-vpc-id" {
    value = aws_vpc.docker-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.docker-subnet-1.id
}

resource "aws_internet_gateway" "docker-igw" {
  vpc_id = aws_vpc.docker-vpc.id
  tags = {
    Name = "${var.env_prefix}-iwg"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.docker-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_security_group" "docker-sg" {
  name        = "docker-sg"
  description = "Allow Docker Traffic"
  vpc_id      = aws_vpc.docker-vpc.id

  ingress {
    description = "Allow from Personal CIDR block"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
  }
  ingress {
    description = "Allow from Personal CIDR block"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

output "instance_ip" {
  value = aws_instance.docker-server.public_ip
}

resource "aws_route_table" "docker-public-rt" {
  vpc_id = aws_vpc.docker-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker-igw.id
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.docker-subnet-1.id
  route_table_id = aws_route_table.docker-public-rt.id
}

data "aws_ami" "amazon-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
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

output "aws_ami" {
  value = data.aws_ami.amazon-image
}

resource "aws_instance" "docker-server" {
  ami                         = data.aws_ami.amazon-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.docker-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.docker-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name 
  tags = {
    Name = "${var.env_prefix}-docker-server"
  }
}

resource "null_resource" "configure-ansible-server" {
  triggers = {
    trigger = aws_instance.docker-server.public_ip
  }

  provisioner "local-exec" {
    working_dir = "${var.project_path}/ansible/"
    command = "chmod 400 ${var.project_path}${var.ssh_key} && ansible-playbook --private-key ${var.project_path}${var.ssh_key} --user ec2-user deploy-docker.yaml"
  }  
}