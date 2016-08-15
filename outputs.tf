output "cassandra_0" {
    value = "${aws_instance.cassandra_0.public_ip}"
}

output "cassandra_1" {
  value = "${aws_instance.cassandra_1.public_ip}"
}

output "cassandra_2" {
  value = "${aws_instance.cassandra_2.public_ip}"
}
