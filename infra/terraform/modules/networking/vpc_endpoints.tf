resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoint_settings

  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.project_settings.aws_region}.${each.key}"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [var.interface_endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_settings.project_name}-${each.key}-interface-endpoint"
  }
}


resource "aws_vpc_endpoint" "gateway" {
  for_each = var.gateway_endpoint_settings

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.project_settings.aws_region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_settings.project_name}-${each.key}-gateway-endpoint"
  }
}

