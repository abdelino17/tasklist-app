# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_network_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }
}

# Define the public subnet
resource "aws_subnet" "subnet_pub" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 1, 0)
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${terraform.workspace}-public-subnet"
    Environment = terraform.workspace
  }
}

# Define the private subnet
resource "aws_subnet" "subnet_priv" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 1, 1)
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${terraform.workspace}-private-subnet"
    Environment = terraform.workspace
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${terraform.workspace}-igw"
    Environment = terraform.workspace
  }
}

# Define the route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${terraform.workspace}-rt"
    Environment = terraform.workspace
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet_pub.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rtb" {
  subnet_id      = aws_subnet.subnet_priv.id
  route_table_id = aws_route_table.rt.id
}

# Define the elastic IPs 
resource "aws_eip" "eip_front" {
  instance   = element(aws_instance.front.*.id, count.index)
  depends_on     = [aws_internet_gateway.igw]
  count = var.count_ec2
  vpc = true
  
  tags = {
    Name = "${terraform.workspace}-front-eip-${count.index + 1}"
    Environment = terraform.workspace
  }
}

resource "aws_eip" "app_front" {
  instance   = element(aws_instance.app.*.id, count.index)
  depends_on     = [aws_internet_gateway.igw]
  count = var.count_ec2
  vpc = true
  
  tags = {
    Name = "${terraform.workspace}-app-eip-${count.index + 1}"
    Environment = terraform.workspace
  }
}

resource "aws_eip" "bdd_eip" {
  vpc            = true
  instance       = aws_instance.bdd.id
  depends_on     = [aws_internet_gateway.igw]
  tags = {
    Name = "${terraform.workspace}-bdd-eip"
    Environment = terraform.workspace
  }
}