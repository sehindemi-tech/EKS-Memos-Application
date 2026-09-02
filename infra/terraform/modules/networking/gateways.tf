resource "aws_eip" "nat_eip" {
  domain = var.eip_domain
  tags = {
    Name = "${var.project_settings.project_name}-eip"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_settings.project_name}-igw"
  }
}