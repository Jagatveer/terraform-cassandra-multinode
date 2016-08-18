module "cassandra_security_group2" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_cassandra"
  security_group_name = "${var.security_group_name}-cassandra"
  vpc_id = "${aws_vpc.cassandra02.id}"
  source_cidr_block = "${var.source_cidr_block2}"
}

resource "aws_vpc" "cassandra02" {
  cidr_block = "${var.cidr02}"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy     = "default"
  tags { Name = "cassandra02" }
}

resource "aws_subnet" "forsinglenode" {
  vpc_id = "${aws_vpc.cassandra02.id}"
  cidr_block = "10.201.14.0/25"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags {
    Name = "${var.user_name}_Forsinglenode"
  }
}

resource "aws_internet_gateway" "gw2" {
  vpc_id = "${aws_vpc.cassandra02.id}"
  tags {
    Name = "${var.user_name}_igw"
  }
}


resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.cassandra02.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw2.id}"
  }
}

resource "aws_network_acl" "forsinglenode" {
  vpc_id = "${aws_vpc.cassandra02.id}"
  subnet_ids = ["${aws_subnet.forsinglenode.id}"]
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
    Name = "${var.user_name}_ForSingleNode"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id = "${aws_subnet.forsinglenode.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_security_group" "allow_internet_access2" {
  name = "allow_internet_access"
  description = "Allow outbound internet communication."
  vpc_id = "${aws_vpc.cassandra02.id}"

  tags {
    Name = "cluster_internet_access"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_ssh_access2" {
  name = "allow_all_ssh_access"
  description = "ALlow ssh access from any ip"
  vpc_id = "${aws_vpc.cassandra02.id}"
  tags {
    Name = "cluster_ssh_rule"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create a separate instance for cassandra

resource "aws_instance" "cassandra_single" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.ssh_key_name}"
  private_ip = "10.201.14.7"
  subnet_id = "${aws_subnet.forsinglenode.id}"
  vpc_security_group_ids = ["${module.cassandra_security_group2.security_group_id}", "${aws_security_group.allow_internet_access2.id}", "${aws_security_group.allow_all_ssh_access2.id}"]
  depends_on = ["aws_internet_gateway.gw2"]

  tags {
    Name = "${var.user_name}_cassandra_single"
  }

  provisioner "remote-exec" {
    inline = ["sudo mkdir -p /tmp/provisioning",
      "sudo chown -R ubuntu:ubuntu  /tmp/provisioning/"]
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }

  provisioner "file" {
    source = "provisioning/single.sh"
    destination = "/tmp/provisioning/single.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }

  provisioner "file" {
    source = "provisioning/backup.bash"
    destination = "/tmp/provisioning/backup.bash"
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }

  provisioner "remote-exec" {
    inline = ["sudo chmod +x /tmp/provisioning/single.sh",
    "sudo chmod +x /tmp/provisioning/backup.bash"]
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }
}
