# My Code

# The following configures the provider in this instance this changes it to be AWS.
provider "aws" {
    # This defines the region that is being configured.
    region = "eu-west-2"
    }

# Example Code

provider "aws" {
  region = "eu-west-2"
}


# My Code

resource "aws_vpc" "sandpit_vpc" {

  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = "10.128.0.0/16"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"

  tags = {
    Name = "sandpit_vpc"
  }
}

# Example Code
resource "aws_vpc" "sandpit_vpc" {
  cidr_block = "10.128.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "Sandpit VPC"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "instance" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.sandpit_vpc.id
  tags = {
    "Name" = "DummySubnetInstance"
  }
}

# My Code (Not covered in code as done in a different method we need to ensure that all of the SSH stuff is removed.

# Example Code

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "DummyMachine"
  public_key = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
}

output "ssh_public_key_pem" {
  value = tls_private_key.ssh.public_key_pem
}

# My Code

resource "aws_internet_gateway" "sandpit_gw" {
    vpc_id = "${aws_vpc.sandpit_vpc.id}"

    tags = {
        Name = "Sandpit Internet Gateway"
    }
  
}

# My Code

# My Code

resource "aws_subnet" "sandpit_subnet-2a" {
    vpc_id = "${aws_vpc.sandpit_vpc.id}"
    cidr_block = "10.128.0.0/16"
    availability_zone = "eu-west-2a"

    depends_on = [aws_internet_gateway.sandpit_gw]

    tags = {
        Name = "Sandpit IP Subnet 2a"
        Zone = "eu-west-2a"
        Range = "10.128.0.0/16"
    }
}

# My Code

# My Code
resource "aws_nat_gateway" "example" {
  #allocation_id = aws_eip.example.id
  subnet_id     = "${aws_subnet.sandpit_subnet-2a.id}"

  tags = {
    Name = "Sandpit NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sandpit_gw]
}

# My Code

# My Code


resource "aws_instance" "openvpn" {
    subnet_id = aws_subnet.sandpit_subnet-2a.id
    ami = "ami-056465a2a49aad6d9"
    instance_type = "t2.micro"
    iam_instance_profile = "SSH-Managed-Instance-Role"
    key_name = "Sandpit-AWS-EC2"

    depends_on = [aws_internet_gateway.sandpit_gw]

    tags = {
        Name = "Open VPN Server"
        Platform = "Linux/UNIX"
        AMI_ID = "ami-056465a2a49aad6d9"

    }
}

# My Code

# My Code

resource "aws_instance" "Dev-Test" {
    subnet_id = aws_subnet.sandpit_subnet-2a.id
    ami = "ami-0ebb4b3e90d89aca4"
    instance_type = "t2.micro"
    iam_instance_profile = "SSH-Managed-Instance-Role"
    key_name = "Sandpit-AWS-EC2"

    depends_on = [aws_internet_gateway.sandpit_gw]

        tags = {
        Name = "Dev / Test Server"
        Platform = "Linux/UNIX"
        AMI_ID = "ami-0ebb4b3e90d89aca4"

    }
}


# My Code

# My Code
resource "aws_eip" "ip-dev-test" {
    instance = "${aws_instance.Dev-Test.id}"
    vpc = true
}


# My Code

# My Code
resource "aws_eip" "ip-openvpn" {
    instance = "${aws_instance.openvpn.id}"
    vpc = true
}

# My Code

# My Code
resource "aws_route_table" "sandpit_routing_2a" {
    vpc_id = "${aws_vpc.sandpit_vpc.id}"
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sandpit_gw.id}"
        }
    tags = {
        Name = "Sandpit Enviroment Route Table"
    }
}

# My Code

# My Code
resource "aws_route_table_association" "subnet-association" {
    subnet_id = "${aws_subnet.sandpit_subnet-2a.id}"
    route_table_id = "${aws_route_table.sandpit_routing_2a.id}"
}

# My Code

# My Code
resource "aws_vpn_gateway" "sandpit_vpn_gateway" { 
    vpc_id = "${aws_vpc.sandpit_vpc.id}"

    tags = {
        Name = "Main VPN Gateway"
    }
}

# My Code

# My Code
resource "aws_network_interface" "Sandpit-White-List-IP"{
    subnet_id = "${aws_subnet.sandpit_subnet-2a.id}"
    private_ips = ["10.128.0.10","10.128.0.11"]
}

# My Code

# My Code
resource "aws_eip" "Sandpit_One" {
    vpc = true
    network_interface = "${aws_network_interface.Sandpit-White-List-IP.id}"
    associate_with_private_ip = "10.128.0.10"
  
}

# My Code

# My Code
resource "aws_eip" "Sandpit_Two" {
    vpc = true
    network_interface = "${aws_network_interface.Sandpit-White-List-IP.id}"
    associate_with_private_ip = "10.128.0.11"
  
}
