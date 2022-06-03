
variable "name" {
  type        = string
  description = "Name prefix fo ec2"
}

variable "ami_id" {
  description = "ami_id of the instance"
   type        = string
}

variable "script_path" {
  description = "path name of scvripts to be executed"
  type = string
}

variable "key_value_pair" {
  type        = string
  description = "Name of the key_value_pair to connect to the instance"
}

variable "ingress" {
  description = "list of ingress security ports"
  type = list
}

variable "instance_type" {
  type        = string
  description = "Instance type of ec2"
}

variable "ec2_user" {
  type        = string
  description = "username for ssh"
}

variable "ip_script_path" {
  description = "path of ip script"
  type = string
}