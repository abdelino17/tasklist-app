# Define the network ACLs for Public subnet
resource "aws_network_acl" "all_public_internal" {

  vpc_id        =  aws_vpc.vpc.id 
  subnet_ids    = [
    aws_subnet.subnet_pub.id
  ]

  egress {
    protocol    = "-1"
    rule_no     = 1
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 4
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 5
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 6
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 7
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024 
    to_port     = 65535
  }

  ingress {
    protocol = "udp"
    rule_no = 9
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    rule_no     = 10
    protocol    = "icmp"
    icmp_type   = -1
    icmp_code   = -1
    from_port   = 0
    to_port     = 0
    cidr_block  = var.aws_network_cidr
    action      = "allow"
  }

  ingress {
    rule_no     = 16
    protocol    = "-1"
    action      = "allow"
    cidr_block  = var.aws_network_cidr
    from_port   = 0
    to_port     = 0
  }

  tags =  {
    Name = "${terraform.workspace}-public-network_acl"
    Environment = terraform.workspace
  }
    
}

# Define the network ACLs for Private subnet
resource "aws_network_acl" "all_private_internal" {

  vpc_id        =  aws_vpc.vpc.id 
  subnet_ids    = [
    aws_subnet.subnet_priv.id
  ]

  egress {
    protocol    = "-1"
    rule_no     = 1
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 4
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 5
    action      = "allow"
    cidr_block  = var.aws_network_cidr
    from_port   = 3306
    to_port     = 3306
  }

  ingress {
    protocol    = "tcp"
    rule_no     = 7
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 1024 
    to_port     = 65535
  }

  ingress {
    protocol = "udp"
    rule_no = 9
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    rule_no     = 10
    protocol    = "icmp"
    icmp_type   = -1
    icmp_code   = -1
    from_port   = 0
    to_port     = 0
    cidr_block  = var.aws_network_cidr
    action      = "allow"
  }


  tags =  {
    Name = "${terraform.workspace}-private-network_acl"
    Environment = terraform.workspace
  }
    
}

# Define the security group for internal traffic
resource "aws_security_group" "allow_internal" {
  name = "internal-allow-all"
  description = "Terraform allow all inbound traffic"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [
        var.aws_network_cidr
    ]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  egress {
    ipv6_cidr_blocks = ["::/0"]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  ingress {
    ipv6_cidr_blocks = ["::/0"]
    from_port = 0
    to_port   = -1
    protocol  = "icmp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8
    to_port   = -1
    protocol  = "icmp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = -1
    protocol  = "icmp"
  }

  ingress {
    ipv6_cidr_blocks = ["::/0"]
    from_port = 0
    to_port   = -1
    protocol  = "icmp"
  }
  
  tags =  {
    Name = "Internal allow all for ${terraform.workspace}-sg"
    Environment = terraform.workspace
  }
}

# Define the security group for SSH connections
resource "aws_security_group" "allow_ssh" {
  name = "ssh-traffic"
  description = "Terraform allow ssh inbound traffic"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = var.authorized_ips
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  
  tags =  {
    Name = "${terraform.workspace}-ssh-sg"
    Environment = terraform.workspace
  }
}

# Define the security group for Web traffic
resource "aws_security_group" "allow_web" {
  name = "web-traffic"
  description = "Terraform allow web inbound traffic"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [
        "0.0.0.0/0"
    ]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
        "0.0.0.0/0"
    ]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  tags =  {
    Name = "${terraform.workspace}-web-sg"
    Environment = terraform.workspace
  }
}

# Define the security group for Rails application
resource "aws_security_group" "allow_rails" {
  name = "rails-traffic"
  description = "Rails inbound traffic"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [
      var.aws_network_cidr
    ]
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
  }
  
  tags =  {
    Name = "${terraform.workspace}-rails-sg"
    Environment = terraform.workspace
  }
}

# Define the security group for Mysql connections
resource "aws_security_group" "allow_mysql" {
  name = "mysql-traffic"
  description = "Mysql inbound traffic"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [
      aws_subnet.subnet_pub.cidr_block
    ]
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }
  
  tags =  {
    Name = "${terraform.workspace}-mysql-sg"
    Environment = terraform.workspace
  }
}