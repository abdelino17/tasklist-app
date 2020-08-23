# Define the ssh key
resource "aws_key_pair" "keypair" {
    key_name            = "${terraform.workspace}-sshkey"
    public_key          =  var.aws_key
}

# Create the front instance
resource "aws_instance" "front" {

    ami                 = var.ubuntu_ami
    subnet_id           = aws_subnet.subnet_pub.id
    instance_type       = "t2.medium"
    count               = var.count_ec2
    vpc_security_group_ids = [
        aws_security_group.allow_internal.id,
        aws_security_group.allow_ssh.id,
        aws_security_group.allow_web.id
    ]
    
    key_name            = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size  = 24
    }  

    ebs_block_device {
        volume_size  = 10
        device_name  = "/dev/sdb"
    }

    tags = {
        Name        = format("front%02s-%s", count.index + 1, terraform.workspace)
        Environment = terraform.workspace
        Role        = "Front"
        Provider    = "aws"
    }

}

# Create the aws instance
resource "aws_instance" "app" {

    ami                 = var.ubuntu_ami
    subnet_id           = aws_subnet.subnet_pub.id
    instance_type       = "t2.medium"
    count               = var.count_ec2
    vpc_security_group_ids = [
        aws_security_group.allow_internal.id,
        aws_security_group.allow_ssh.id,
        aws_security_group.allow_rails.id
    ]
    
    key_name            = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size  = 24
    }  

    ebs_block_device {
        volume_size  = 10
        device_name  = "/dev/sdb"
    }

    tags = {
        Name        = format("app%02s-%s", count.index + 1, terraform.workspace)
        Environment = terraform.workspace
        Role        = "App"
        Provider    = "aws"
    }

}

# Create the bdd instance
resource "aws_instance" "bdd" {

    ami                 = var.ubuntu_ami
    subnet_id           = aws_subnet.subnet_priv.id
    instance_type       = "t2.medium"
    vpc_security_group_ids = [
        aws_security_group.allow_internal.id,
        aws_security_group.allow_ssh.id,
        aws_security_group.allow_mysql.id
    ]
    
    key_name            = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size  = 24
    }  

    tags = {
        Name        = format("bdd01-%s", terraform.workspace)
        Environment = terraform.workspace
        Role        = "BDD"
        Provider    = "aws"
    }

}