resource "aws_instance" "cassandra_0" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.ssh_key_name}"
  private_ip = "10.2.5.170"
  subnet_id = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${module.cassandra_security_group.security_group_id}", "${aws_security_group.allow_internet_access.id}", "${aws_security_group.allow_all_ssh_access.id}"]
  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "${var.user_name}_cassandra_0"
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
    source = "provisioning/setup_cassandra.sh"
    destination = "/tmp/provisioning/setup_cassandra.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }
}


resource "aws_instance" "cassandra_1" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.ssh_key_name}"
  private_ip = "10.2.5.171"
  subnet_id = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${module.cassandra_security_group.security_group_id}", "${aws_security_group.allow_internet_access.id}", "${aws_security_group.allow_all_ssh_access.id}"]
  depends_on = ["aws_internet_gateway.gw", "aws_instance.cassandra_0"]

  tags {
    Name = "${var.user_name}_cassandra_1"
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
    source = "provisioning/setup_cassandra.sh"
    destination = "/tmp/provisioning/setup_cassandra.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }
}


resource "aws_instance" "cassandra_2" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.ssh_key_name}"
  private_ip = "10.2.5.172"
  subnet_id = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${module.cassandra_security_group.security_group_id}", "${aws_security_group.allow_internet_access.id}", "${aws_security_group.allow_all_ssh_access.id}"]
  depends_on = ["aws_internet_gateway.gw", "aws_instance.cassandra_1"]

  tags {
    Name = "${var.user_name}_cassandra_2"
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
    source = "provisioning/setup_cassandra.sh"
    destination = "/tmp/provisioning/setup_cassandra.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      key_file = "${var.ssh_key_path}"
    }
  }
}

resource "aws_ebs_volume" "cassandra_0" {
  availability_zone = "us-west-2a"
  size = 500
  type = "gp2"

  tags {
    Name = "${var.user_name}_cassandra_0"
  }
}

resource "aws_ebs_volume" "cassandra_1" {
  availability_zone = "us-west-2a"
  size = 500
  type = "gp2"

  tags {
    Name = "${var.user_name}_cassandra_1"
  }
}

resource "aws_ebs_volume" "cassandra_2" {
  availability_zone = "us-west-2a"
  size = 500
  type = "gp2"

  tags {
    Name = "${var.user_name}_cassandra_2"
  }
}

resource "aws_volume_attachment" "cassandra_0_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_0.id}"
  instance_id = "${aws_instance.cassandra_0.id}"
}

resource "aws_volume_attachment" "cassandra_1_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_1.id}"
  instance_id = "${aws_instance.cassandra_1.id}"
}

resource "aws_volume_attachment" "cassandra_2_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_2.id}"
  instance_id = "${aws_instance.cassandra_2.id}"
}
