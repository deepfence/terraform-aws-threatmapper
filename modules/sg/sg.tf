

variable "ingress" {
  type    = list(number)
  default = [80, 443, 22]
}


module "vpcmodule" {
    source = "../vpc"
}



output "sg_name" {
  value = aws_security_group.web_traffic.name
}

output "sg_id" {
  value = aws_security_group.web_traffic.id
}

resource "aws_security_group" "web_traffic" {
  name = "Allow Web Traffic"
  vpc_id = module.vpcmodule.vpc_id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
