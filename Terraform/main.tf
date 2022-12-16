provider "aws" {
    region = "us-east-1"
    access_key = "AKIAXNN3QHXZ2TKCBKNJ"
    secret_key = "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"
}

resource "aws_vpc" "project-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "project-vpc"
    }
}

resource "aws_subnet" "project-public-subnet" {
    vpc_id = aws_vpc.project-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "project-public-subnet"
    }
}

resource "aws_internet_gateway" "project-igw" {
    vpc_id = aws_vpc.project-vpc.id
    tags = {
        Name = "project-igw"
    }
  
}

resource "aws_route_table" "project-rt" {
    vpc_id= aws_vpc.project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.project-igw.id
    }
    tags = {
      "Name" = "project-rt"
    }
}

resource "aws_route_table_association" "project-rt-association" {
    subnet_id = aws_subnet.project-public-subnet.id
    route_table_id = aws_route_table.project-rt.id
}

resource "aws_security_group" "project-security-group" {

    name = "project-security-group"
    vpc_id = aws_vpc.project-vpc.id
    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "project-security-group"
  }
  
}
resource "aws_instance" "project-tf-ansible" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    key_name = "ec2-key"
    associate_public_ip_address = true
    security_groups = [aws_security_group.project-security-group.id]
    subnet_id = aws_subnet.project-public-subnet.id
    provisioner "remote-exec" {
    inline                  = [
        "sudo apt update -y",
        "sudo apt install ansible -y"
    ]

    connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("ec2-key.pem")
        host                = coalesce(self.public_ip,self.private_ip) 
    }
  }
  tags = {
    "Name" = "project-tf-ansible"
  }
}

resource "aws_instance" "project-jenkins" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    key_name = "ec2-key"
    associate_public_ip_address = true
    security_groups = [aws_security_group.project-security-group.id]  
    subnet_id = aws_subnet.project-public-subnet.id 
    tags ={
        "Name" = "project-jenkins"
    } 
}
