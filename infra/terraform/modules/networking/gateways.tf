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
  allocation_id     = aws_eip.nat_eip.id
  availability_mode = var.nat_gateway_settings.availability_mode
  connectivity_type = var.nat_gateway_settings.connectivity_type
  vpc_id            = aws_vpc.this.id
  tags = {
    Name = "${var.project_settings.project_name}-zonal-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}

