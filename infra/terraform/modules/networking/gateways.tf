resource "aws_eip" "nat_eip" {
  domain = var.eip_domain
}

