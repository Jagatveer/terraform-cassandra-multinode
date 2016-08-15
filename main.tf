module "cassandra_security_group" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_cassandra"
  security_group_name = "${var.security_group_name}-cassandra"
  vpc_id = "${aws_vpc.cassandra.id}"
  source_cidr_block = "${var.source_cidr_block}"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "cassandra" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy     = "default"
  tags { Name = "cassandra" }
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.cassandra.id}"
  cidr_block = "10.2.5.128/25"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags {
    Name = "${var.user_name}_Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.cassandra.id}"
  tags {
    Name = "${var.user_name}"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.cassandra.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.cassandra.id}"
  subnet_ids = ["${aws_subnet.main.id}"]
  egress{
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  ingress {
    protocol = "all"
    rule_no = 1
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags {
    Name = "${var.user_name}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_security_group" "allow_internet_access" {
  name = "allow_internet_access"
  description = "Allow outbound internet communication."
  vpc_id = "${aws_vpc.cassandra.id}"

  tags {
    Name = "cluster_internet"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_ssh_access" {
  name = "allow_all_ssh_access"
  description = "ALlow ssh access from any ip"
  vpc_id = "${aws_vpc.cassandra.id}"
  tags {
    Name = "cluster_ssh"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
