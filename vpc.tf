#create VPC
resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}

# create public subnet
resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "My_public-vpc"
  }
}

#create private subnet
resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "My_private_vpc"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my_igw"
  }
}

#create route public table

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-route"
  } 
}

#create public subnet association

resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.public-sub.id
  route_table_id = aws_route_table.pub-rt.id
}

#create Elastic IP for NAT
resource "aws_eip" "elastic-ip" {
  domain   = "vpc"
}

#create NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.public-sub.id

  tags = {
    Name = "gw NAT"
  }
}

#create route private table

resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "pri-route"
  }
}

#create private subnet association

resource "aws_route_table_association" "pri" {
  subnet_id      = aws_subnet.private-sub.id
  route_table_id = aws_route_table.pri-rt.id
}

#creating security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.my-vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "1" # semantically equivalent to all ports
  to_port           = -1
}


# EC2 Instance
resource "aws_instance" "my_instance" {
  ami                    = "ami-0d682f26195e9ec0f"  # Replace with a valid AMI for your region
  instance_type          = "t2.micro"              # Choose your instance type
  subnet_id              = aws_subnet.public-sub.id
  security_groups        = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  key_name               = "3tier-app"  # Replace with your SSH key name
  tags = {
    Name = "my-ec2-instance" 
 }
}

resource "aws_instance" "my_instance2" {
  ami                    = "ami-0d682f26195e9ec0f"  # Replace with a valid AMI for your region
  instance_type          = "t2.micro"              # Choose your instance type
  subnet_id              = aws_subnet.private-sub.id
  security_groups        = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  key_name               = "3tier-app"  # Replace with your SSH key name
  tags = {
    Name = "my-ec2-instance"
  }
}
