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
resource "aws_vpc" "template2-yousra-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "template2-yousra-VPC"
        }
}
resource "aws_subnet" "template2-yousra-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "template2-yousra-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "template2-yousra-SUBNET-PRIVATE" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        cidr_block = "10.0.2.0/24"
        tags = {
                Name = "template2-yousra-SUBNET-PRIVATE"
        }
}
resource "aws_internet_gateway" "template2-yousra-IGW" {
        tags = {
                Name = "template2-yousra-IGW"
        }
}
resource "aws_internet_gateway_attachment" "template2-yousra-IGW-ATTACH" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.template2-yousra-IGW.id}"
}
resource "aws_route_table" "template2-yousra-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.template2-yousra-IGW.id}"
        }
        tags = {
                Name = "template2-yousra-RTB-PUBLIC"
        }
}
resource "aws_eip" "template2-yousra-EIP" {
}
resource "aws_nat_gateway" "template2-yousra-NATGW" {
        subnet_id = "${aws_subnet.template2-yousra-SUBNET-PUBLIC.id}"
        allocation_id = "${aws_eip.template2-yousra-EIP.id}"
        tags = {
                Name = "template2-yousra-NATGW"
        }
}
resource "aws_route_table" "template2-yousra-RTB-PRIVATE" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = "${aws_nat_gateway.template2-yousra-NATGW.id}"
        }
        tags = {
                Name = "template2-yousra.RTB-PRIVATE"
        }
}
resource "aws_route_table_association" "template2-yousra-RTB-PRIVATE-ASSOC" {
        subnet_id = "${aws_subnet.template2-yousra-SUBNET-PRIVATE.id}"
        route_table_id = "${aws_route_table.template2-yousra-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "template2-yousra-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.template2-yousra-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.template2-yousra-RTB-PUBLIC.id}"
}
resource "aws_security_group" "template2-yousra-SG-PUBLIC" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
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
                Name = "template2-yousra-SG-PUBLIC"
        }
}
resource "aws_security_group" "template2-yousra-SG-PRIVATE" {
        vpc_id = "${aws_vpc.template2-yousra-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.template2-yousra-SG-PUBLIC.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "template2-yousra-SG-PUBLIC"
        }
}
resource "aws_instance" "template2-yousra-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.template2-yousra-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.template2-yousra-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        tags = {
                Name = "template2-yousra-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "template2-yousra-INSTANCE-PRIVATE" {
        subnet_id = "${aws_subnet.template2-yousra-SUBNET-PRIVATE.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.template2-yousra-SG-PRIVATE.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "template2-yousra-INSTANCE-PRIVATE"
        }
}
