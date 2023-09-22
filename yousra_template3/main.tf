terraform {
        required_providers {
                aws = {
                        source  = "hashicorp/aws"
                }
        }
}
provider "aws" {
        region = "us-east-1"
}
resource "aws_vpc" "yousra_template3-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "yousra_template3-VPC"
        }
}
resource "aws_subnet" "yousra_template3-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "yousra_template3-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "yousra_template3-SUBNET-PRIVATE" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        cidr_block = "10.0.2.0/24"
        tags = {
                Name = "yousra_template3-SUBNET-PRIVATE"
        }
}
resource "aws_internet_gateway" "yousra_template3-IGW" {
        tags = {
                Name = "yousra_template3-IGW"
        }
}
resource "aws_internet_gateway_attachment" "yousra_template3-IGW-ATTACH" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.yousra_template3-IGW.id}"
}
resource "aws_route_table" "yousra_template3-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.yousra_template3-IGW.id}"
        }
        tags = {
                Name = "yousra_template3-RTB-PUBLIC"
        }
}
resource "aws_eip" "yousra_template3-EIP" {
}
resource "aws_nat_gateway" "yousra_template3-NATGW" {
        subnet_id = "${aws_subnet.yousra_template3-SUBNET-PUBLIC.id}"
        allocation_id = "${aws_eip.yousra_template3-EIP.id}"
        tags = {
                Name = "yousra_template3-NATGW"
        }
}
resource "aws_route_table" "yousra_template3-RTB-PRIVATE" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = "${aws_nat_gateway.yousra_template3-NATGW.id}"
        }
        tags = {
                Name = "yousra_template3.RTB-PRIVATE"
        }
}
resource "aws_route_table_association" "yousra_template3-RTB-PRIVATE-ASSOC" {
        subnet_id = "${aws_subnet.yousra_template3-SUBNET-PRIVATE.id}"
        route_table_id = "${aws_route_table.yousra_template3-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "yousra_template3-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.yousra_template3-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.yousra_template3-RTB-PUBLIC.id}"
}
resource "aws_security_group" "yousra_template3-SG-PUBLIC" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "yousra_template3-SG-PUBLIC"
        }
}
resource "aws_security_group" "yousra_template3-SG-PRIVATE" {
        vpc_id = "${aws_vpc.yousra_template3-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.yousra_template3-SG-PUBLIC.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "yousra_template3-SG-PUBLIC"
        }
}
resource "aws_instance" "yousra_template3-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.yousra_template3-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.yousra_template3-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        user_data = "${templatefile("rproxy.tpl", { WEB_IP = "${aws_instance.yousra_template3-INSTANCE-PRIVATE.private_ip}" })}"
        tags = {
                Name = "yousra_template3-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "yousra_template3-INSTANCE-PRIVATE" {
        subnet_id = "${aws_subnet.yousra_template3-SUBNET-PRIVATE.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.yousra_template3-SG-PRIVATE.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "yousra_template3-INSTANCE-PRIVATE"
        }
}
