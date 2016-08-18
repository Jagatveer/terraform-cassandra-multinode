variable "user_name" { default = "ubuntu" }
variable "access_key" { default = "" }
variable "secret_key" { default = "" }
variable "ssh_key_path" { default = "./terraform_psnl.pem" }
variable "ssh_key_name" { default = "terraform_psnl" }
variable "cidr" { default = "10.2.4.0/23" }
variable "cidr02" { default = "10.201.14.0/23" }
variable "instance_type" { default = "m3.large" }
#variable "vpc_id" {}
variable "security_group_name" { default = "terraform" }
variable "ami" { default = "ami-412dcf21" }

# default source_cidr_block is the main subnet
# defined in aws_subnet.main.cidr_block.
variable "source_cidr_block" { default = "10.2.5.128/25" }
variable "source_cidr_block2" { default = "10.201.14.0/25" }
variable "region" { default = "us-west-2" }
