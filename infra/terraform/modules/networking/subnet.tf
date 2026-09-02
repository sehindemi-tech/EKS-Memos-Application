#trivy:ignore:AWS-0164 Public Subnet needed for Nat and LB
resource "aws_subnet" "public" {
  for_each                = { for k, v in var.subnet_settings : k => v if v.is_public }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.key
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each                = { for k, v in var.subnet_settings : k => v if !v.is_public }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.key
    Tier = "private"
  }
}