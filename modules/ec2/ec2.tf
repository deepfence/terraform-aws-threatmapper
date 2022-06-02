
module "vpc" {
  source = "../vpc"
  ingress = var.ingress
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }

resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.subnet_id
  key_name                    = aws_key_pair.threatmapper-key-pair.id
  vpc_security_group_ids      = [module.vpc.sg_id]
  tags = {
    Name = "terraform_threatmapper"
  }
  provisioner "file" {
    source      = var.script_path
    destination = "/tmp/threatmapper.sh"
  }
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/threatmapper.sh",
        "sudo /tmp/threatmapper.sh"
    ]
   }
   connection {
        host = self.public_ip
        user = var.ec2_user
        private_key = "${file(var.key_value_pair)}"
        
    }
}


resource "aws_key_pair" "threatmapper-key-pair" {
    key_name = var.key_value_pair
    public_key = "${file("${var.key_value_pair}.pub")}"
}








output "instance_id" {
  value = aws_instance.ec2.id
}
