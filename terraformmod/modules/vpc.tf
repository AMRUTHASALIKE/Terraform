resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}

output "vpc_id" {
  value = "${aws_vpc.vpc1.id}"
}

output "route_table_id" {
  value = "${aws_vpc.vpc1.main_route_table_id}"
}

