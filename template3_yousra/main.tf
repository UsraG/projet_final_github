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
resource "aws_vpc" "template3_yousra-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "template3_yousra-VPC"
        }
}
resource "aws_subnet" "template3_yousra-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "template3_yousra-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "template3_yousra-SUBNET-PRIVATE" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        cidr_block = "10.0.2.0/24"
        tags = {
                Name = "template3_yousra-SUBNET-PRIVATE"
        }
}
resource "aws_internet_gateway" "template3_yousra-IGW" {
        tags = {
                Name = "template3_yousra-IGW"
        }
}
resource "aws_internet_gateway_attachment" "template3_yousra-IGW-ATTACH" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.template3_yousra-IGW.id}"
}
resource "aws_route_table" "template3_yousra-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.template3_yousra-IGW.id}"
        }
        tags = {
                Name = "template3_yousra-RTB-PUBLIC"
        }
}
resource "aws_eip" "template3_yousra-EIP" {
}
resource "aws_nat_gateway" "template3_yousra-NATGW" {
        subnet_id = "${aws_subnet.template3_yousra-SUBNET-PUBLIC.id}"
        allocation_id = "${aws_eip.template3_yousra-EIP.id}"
        tags = {
                Name = "template3_yousra-NATGW"
        }
}
resource "aws_route_table" "template3_yousra-RTB-PRIVATE" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = "${aws_nat_gateway.template3_yousra-NATGW.id}"
        }
        tags = {
                Name = "template3_yousra.RTB-PRIVATE"
        }
}
resource "aws_route_table_association" "template3_yousra-RTB-PRIVATE-ASSOC" {
        subnet_id = "${aws_subnet.template3_yousra-SUBNET-PRIVATE.id}"
        route_table_id = "${aws_route_table.template3_yousra-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "template3_yousra-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.template3_yousra-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.template3_yousra-RTB-PUBLIC.id}"
}
resource "aws_security_group" "template3_yousra-SG-PUBLIC" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
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
                Name = "template3_yousra-SG-PUBLIC"
        }
}
resource "aws_security_group" "template3_yousra-SG-PRIVATE" {
        vpc_id = "${aws_vpc.template3_yousra-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.template3_yousra-SG-PUBLIC.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "template3_yousra-SG-PUBLIC"
        }
}
resource "aws_instance" "template3_yousra-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.template3_yousra-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.template3_yousra-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        user_data = "${templatefile("rproxy.tpl", { WEB_IP = "${aws_instance.template3_yousra-INSTANCE-PRIVATE.private_ip}" })}"
        tags = {
                Name = "template3_yousra-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "template3_yousra-INSTANCE-PRIVATE" {
        subnet_id = "${aws_subnet.template3_yousra-SUBNET-PRIVATE.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.template3_yousra-SG-PRIVATE.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "template3_yousra-INSTANCE-PRIVATE"
        }
}
