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
resource "aws_vpc" "YOUSRA-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "YOUSRA-VPC"
        }
}
resource "aws_subnet" "YOUSRA-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "YOUSRA-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "YOUSRA-SUBNET-AZ-A" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        cidr_block = "10.0.2.0/24"
        availability_zone = "us-east-1a"
        tags = {
                Name = "YOUSRA-SUBNET-AZ-A"
        }
}
resource "aws_subnet" "YOUSRA-SUBNET-AZ-B" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        cidr_block = "10.0.3.0/24"
        availability_zone = "us-east-1b"
        tags = {
                Name = "YOUSRA-SUBNET-AZ-B"
        }
}
resource "aws_subnet" "YOUSRA-SUBNET-AZ-C" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        cidr_block = "10.0.4.0/24"
        availability_zone = "us-east-1c"
        tags = {
                Name = "YOUSRA-SUBNET-AZ-C"
        }
}
resource "aws_internet_gateway" "YOUSRA-IGW" {
        tags = {
                Name = "YOUSRA-IGW"
        }
}
resource "aws_internet_gateway_attachment" "YOUSRA-IGW-ATTACH" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.YOUSRA-IGW.id}"
}
resource "aws_route_table" "YOUSRA-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.YOUSRA-IGW.id}"
        }
        tags = {
                Name = "YOUSRA-RTB-PUBLIC"
        }
}
resource "aws_route_table_association" "YOUSRA-RTB-PUBLIC-ASSOC1" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-A.id}"
        route_table_id = "${aws_route_table.YOUSRA-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "YOUSRA-RTB-PUBLIC-ASSOC2" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-B.id}"
        route_table_id = "${aws_route_table.YOUSRA-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "YOUSRA-RTB-PUBLIC-ASSOC3" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-C.id}"
        route_table_id = "${aws_route_table.YOUSRA-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "YOUSRA-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.YOUSRA-RTB-PUBLIC.id}"
}
resource "aws_security_group" "YOUSRA-SG-PUBLIC" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "3128"
                to_port = "3128"
                protocol = "tcp"
                security_groups = ["${aws_security_group.YOUSRA-SG-WEB.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "YOUSRA-SG-PUBLIC"
        }
}
resource "aws_security_group" "YOUSRA-SG-LOAD-BALANCER" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        ingress {
                from_port = "80"
                to_port = "80"
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
                Name = "YOUSRA-SG-LOAD-BALANCER"
        }
}
resource "aws_security_group" "YOUSRA-SG-WEB" {
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.YOUSRA-SG-LOAD-BALANCER.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "YOUSRA-SG-PUBLIC"
        }
}
resource "aws_instance" "YOUSRA-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-053b0d53c279acc90"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.YOUSRA-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        user_data = file("squid.sh")
        tags = {
                Name = "YOUSRA-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "YOUSRA-INSTANCE-AZ-A" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-A.id}"
        instance_type = "t2.micro"
        ami = "ami-053b0d53c279acc90"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.YOUSRA-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.YOUSRA-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "YOUSRA-INSTANCE-AZ-A"
        }
}
resource "aws_instance" "YOUSRA-INSTANCE-AZ-B" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-B.id}"
        instance_type = "t2.micro"
        ami = "ami-053b0d53c279acc90"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.YOUSRA-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.YOUSRA-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "YOUSRA-INSTANCE-AZ-B"
        }
}
resource "aws_instance" "YOUSRA-INSTANCE-AZ-C" {
        subnet_id = "${aws_subnet.YOUSRA-SUBNET-AZ-C.id}"
        instance_type = "t2.micro"
        ami = "ami-053b0d53c279acc90"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.YOUSRA-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.YOUSRA-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "YOUSRA-INSTANCE-AZ-C"
        }
}
resource "aws_lb" "YOUSRA-LB" {
        name = "YOUSRA-LB"
        subnets = ["${aws_subnet.YOUSRA-SUBNET-AZ-A.id}", "${aws_subnet.YOUSRA-SUBNET-AZ-B.id}", "${aws_subnet.YOUSRA-SUBNET-AZ-C.id}"]
        security_groups = ["${aws_security_group.YOUSRA-SG-LOAD-BALANCER.id}"]
}
resource "aws_lb_target_group" "YOUSRA-LB-TG2" {
        name = "YOUSRA-LB-TG2"
        port = 80
        protocol = "HTTP"
        vpc_id = "${aws_vpc.YOUSRA-VPC.id}"
        target_type = "instance"
}
resource "aws_lb_target_group_attachment" "YOUSRA-LB-TG2-ATTACH-1" {
        target_group_arn = "${aws_lb_target_group.YOUSRA-LB-TG2.arn}"
        target_id = "${aws_instance.YOUSRA-INSTANCE-AZ-A.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "YOUSRA-LB-TG2-ATTACH-2" {
        target_group_arn = "${aws_lb_target_group.YOUSRA-LB-TG2.arn}"
        target_id = "${aws_instance.YOUSRA-INSTANCE-AZ-B.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "YOUSRA-LB-TG2-ATTACH-3" {
        target_group_arn = "${aws_lb_target_group.YOUSRA-LB-TG2.arn}"
        target_id = "${aws_instance.YOUSRA-INSTANCE-AZ-C.id}"
        port = 80
}
resource "aws_lb_listener" "YOUSRA-LB-LISTENER" {
        load_balancer_arn = "${aws_lb.YOUSRA-LB.arn}"
        port = "80"
        protocol = "HTTP"
        default_action {
                type = "forward"
                target_group_arn = "${aws_lb_target_group.YOUSRA-LB-TG2.arn}"
        }
}
