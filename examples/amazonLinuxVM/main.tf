

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

variable "region" {
  type        = string
  description = "Enter the aws region"
}

variable "script_path" {
  type        = string
  default  = "../scripts/threatmapperAmazonLinux.sh"
}

variable "ingress" {
  type    = list(number)
  default = [80, 443, 22]
}

variable "instance_type" {
  type    = string
  default = "t2.2xlarge"
}


variable "access_key" {
  type        = string
  description = "Enter the access key of the aws account "
}

variable "ec2_user" {
  type        = string
  default = "ec2-user"
}

variable "secret_key" {
  type        = string
  description = "Enter the secret key of the account"
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}




provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "ec2module" {
  source = "../../modules/ec2"
  name = "aws_threatmapper"
  ami_id = data.aws_ami.amazon_linux_2.id
  key_value_pair = "threatmapper-key-pair"
  ingress = var.ingress
  script_path = var.script_path
  instance_type = var.instance_type
  ec2_user = var.ec2_user

}

output "ec2_id" {
    value = module.ec2module.instance_id
}

