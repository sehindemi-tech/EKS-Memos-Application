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

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public["Public-Subnet-1"].id
  tags = {
    Name = "${var.project_settings.project_name}-zonal-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}

