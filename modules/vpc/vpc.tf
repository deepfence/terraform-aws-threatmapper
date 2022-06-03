resource "aws_vpc" "tm-vpc" {
    cidr_block = "172.31.0.0/16"
    enable_dns_support = true #gives you an internal domain name
    enable_dns_hostnames = true #gives you an internal host name
    enable_classiclink = false
    instance_tenancy = "default"    
    
    tags = {
        Name = "tm-vpc"
    }
}

resource "aws_subnet" "tm-subnet-public-1" {
    vpc_id = aws_vpc.tm-vpc.id
    cidr_block = "172.31.0.0/20"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-east-1a"
    tags = {
        Name = "tm-subnet-public-1"
    }
}

resource "aws_internet_gateway" "tm-igw" {
    vpc_id = aws_vpc.tm-vpc.id
    tags = {
        Name = "tm-igw"
    }
}


resource "aws_route_table" "tm-public-crt" {
    vpc_id = "${aws_vpc.tm-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.tm-igw.id}" 
    }
    
    tags = {
        Name = "tm-public-crt"
    }
}

resource "aws_route_table_association" "tm-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.tm-subnet-public-1.id}"
    route_table_id = "${aws_route_table.tm-public-crt.id}"
}


data "external" "whatismyip" {
  program = ["/bin/bash" , "${path.module}/${var.ip_script_path}"]
}



resource "aws_security_group" "web_traffic" {
  name = "Allow Web Traffic"
  vpc_id = aws_vpc.tm-vpc.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
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

output "vpc_id" {
  value = aws_vpc.tm-vpc.id
}

output "subnet_id" {
  value = aws_subnet.tm-subnet-public-1.id
}

output "sg_name" {
  value = aws_security_group.web_traffic.name
}

output "sg_id" {
  value = aws_security_group.web_traffic.id
}