variable "aws_region" {
  description = "AWS region to create resources"
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR Block"
  default     = "10.0.1.0/24"
}

variable "avail_zone" {
  description = "Subnet Avaiablility Zone"
  default     = "eu-west-1a"
}

variable "env_prefix" {
  description = "Environment"
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 Instance Machine"
  default     = "t2.micro"
}

variable "ssh_key" {
  description = "EC2 SSH key"
  default = "/terraform/ec2-key-pair.pem"
}

variable "project_path" {
  description = "Project Path"
  default = "/Users/itstar/Documents/Programming/Github/devops-project"
}