#trivy:ignore:AWS-0164 Public Subnet needed for Nat and LB
resource "aws_subnet" "this" {
  for_each                = var.subnet_settings
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.key
    Tier = each.value.is_public ? "public" : "private"
  }
}



