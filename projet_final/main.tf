
terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			}
		}

}

provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "PROJETFINAL-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "PROJETFINAL-VPC"
        }
}

resource "aws_subnet" "PROJETFINAL-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "PROJETFINAL-SUBNET-PUBLIC"
        }
}

resource "aws_subnet" "PROJETFINAL-SUBNET-AZ-A" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        cidr_block = "10.0.2.0/24"
        availability_zone = "us-east-1a"
        tags = {
                Name = "PROJETFINAL-SUBNET-AZ-A"
        }
}

resource "aws_subnet" "PROJETFINAL-SUBNET-AZ-B" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        cidr_block = "10.0.3.0/24"
        availability_zone = "us-east-1b"
        tags = {
                Name = "PROJETFINAL-SUBNET-AZ-B"
        }
}

resource "aws_subnet" "PROJETFINAL-SUBNET-AZ-C" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        cidr_block = "10.0.4.0/24"
        availability_zone = "us-east-1c"
        tags = {
                Name = "PROJETFINAL-SUBNET-AZ-C"
        }
}

resource "aws_internet_gateway" "PROJETFINAL-IGW" {
        tags = {
                Name = "PROJETFINAL-IGW"
        }
}

resource "aws_internet_gateway_attachment" "PROJETFINAL-IGW-ATTACH" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.PROJETFINAL-IGW.id}"
}

resource "aws_route_table" "PROJETFINAL-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.PROJETFINAL-IGW.id}"
        }
        tags = {
                Name = "PROJETFINAL-RTB-PUBLIC"
        }
}

resource "aws_route_table_association" "PROJETFINAL-RTB-PUBLIC-ASSOC1" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-A.id}"
        route_table_id = "${aws_route_table.PROJETFINAL-RTB-PUBLIC.id}"
}

resource "aws_route_table_association" "PROJETFINAL-RTB-PUBLIC-ASSOC2" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-B.id}"
        route_table_id = "${aws_route_table.PROJETFINAL-RTB-PUBLIC.id}"
}

resource "aws_route_table_association" "PROJETFINAL-RTB-PUBLIC-ASSOC3" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-C.id}"
        route_table_id = "${aws_route_table.PROJETFINAL-RTB-PUBLIC.id}"
}

resource "aws_route_table_association" "PROJETFINAL-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.PROJETFINAL-RTB-PUBLIC.id}"
}

resource "aws_security_group" "PROJETFINAL-SG-PUBLIC" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
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
                security_groups = ["${aws_security_group.PROJETFINAL-SG-WEB.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "PROJETFINAL-SG-PUBLIC"
        }
}

resource "aws_security_group" "PROJETFINAL-SG-WEB" {
        vpc_id = "${aws_vpc.PROJETFINAL-VPC.id}"
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
                Name = "PROJETFINAL-SG-PUBLIC"
        }
}

resource "aws_instance" "PROJETFINAL-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        tags = {
                Name = "PROJETFINAL-INSTANCE-PUBLIC"
        }
}


resource "aws_instance" "Proxy" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-PUBLIC.id}"]
        associate_public_ip_address = true
	user_data = "${templatefile("rproxy.tpl", {
    		WEB_IP1 = "${aws_instance.PROJETFINAL-INSTANCE-AZ-A.private_ip}",
    		WEB_IP2 = "${aws_instance.PROJETFINAL-INSTANCE-AZ-B.private_ip}",
    		WEB_IP3 = "${aws_instance.PROJETFINAL-INSTANCE-AZ-C.private_ip}"})}"
        tags = {
                Name = "Proxy"
        }
}

resource "aws_instance" "Reverse_Proxy" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-PUBLIC.id}"]
        associate_public_ip_address = true 
	user_data = file("proxy.sh")
        tags = {
                Name = "Reverse_Proxy"
        }
} 

resource "aws_instance" "Admin_MAchine" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        tags = {
                Name = "Admin_Machine"
        }
}

resource "aws_instance" "PROJETFINAL-INSTANCE-AZ-A" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-A.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-WEB.id}"]
        associate_public_ip_address = false
	user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.PROJETFINAL-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "PROJETFINAL-INSTANCE-AZ-A"
        }
}


resource "aws_instance" "PROJETFINAL-INSTANCE-AZ-B" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-B.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-WEB.id}"]
        associate_public_ip_address = false
	user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.PROJETFINAL-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "PROJETFINAL-INSTANCE-AZ-B"
        }
}

resource "aws_instance" "PROJETFINAL-INSTANCE-AZ-C" {
        subnet_id = "${aws_subnet.PROJETFINAL-SUBNET-AZ-C.id}"
        instance_type = "t2.micro"
        ami = "ami-03a6eaae9938c858c"
        key_name = "key-yousra"
        vpc_security_group_ids = ["${aws_security_group.PROJETFINAL-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.PROJETFINAL-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "PROJETFINAL-INSTANCE-AZ-C"
        }
}
