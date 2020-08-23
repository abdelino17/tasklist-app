variable "aws_network_cidr" {
  type    = string
  default = "10.1.0.0/24"
}

variable "authorized_ips" {
  type    = list
  default = ["157.159.44.42/32"]
  #default = ["0.0.0.0/0"
}

variable "ubuntu_ami" {
  type    = string
  default = "ami-03d4fca0a9ced3d1f"
}

variable "aws_key" {
  type    = string 
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChYDw/J8J8ig31W2PLHbE9KlYipLy07fMm1/zPpT0Hesv3VZuvtokWVf2pMg8Ba/qA/X0FwNBq4uXFVfLFByQvDkcsNFw9yJ12W+n7SCoffNvh+Q6IBi32LkHCx8HQ6z8gVG/6/kSwtXzCWLvpVvwkY9eJMwMi7s6gCmxemW7C6lOMULslfN25ujpKQdssFB6BbbG18TccGuVv84gXMNYXcxlxX94D1udqGKIRnoh2XJOMFj9aSPf8NPFhWElbTUi3J/nQBQrxC4GfH3XPpO4F+0RTP7gaOyCLnQDp/Sro/DzwHqBFr8anx0qi+BdekH+/vpBXXWjakP25OeJL43Nb adminsys@LAPTOP-0GJ4J29A"
}

variable "count_ec2" {
  type    = number
  default = 1
}

output "Front_IP" {
    value = "${join(", ", aws_instance.front.*.public_ip)}"
}

output "APP_IP" {
    value = "${join(", ", aws_instance.app.*.public_ip)}"
}

output "DATABASE_IP" {
    value = "${aws_instance.bdd.public_dns} (${aws_instance.bdd.public_ip})"
}