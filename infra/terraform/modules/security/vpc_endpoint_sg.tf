resource "aws_security_group" "vpc_interface_endpoints" {
  name_prefix = "${var.project_settings.project_name}-vpce-"
  description = "Allow HTTPS from within the VPC to interface endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_settings.project_name}-vpc-endpoints-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_ingress_interface_endpoints_https" {
  security_group_id = aws_security_group.vpc_interface_endpoints.id
  description       = var.vpc_ingress_interface_endpoint_sg.ingress_description
  ip_protocol       = var.vpc_ingress_interface_endpoint_sg.ip_protocol
  from_port         = var.vpc_ingress_interface_endpoint_sg.from_port
  to_port           = var.vpc_ingress_interface_endpoint_sg.to_port
  cidr_ipv4         = var.vpc_cidr

  tags = {
    Name = "${var.project_settings.project_name}-vpce-ingress-https"
  }
}

#trivy:ignore:AWS-0104
resource "aws_vpc_security_group_egress_rule" "egress_vpc_endpoints_all" {
  security_group_id = aws_security_group.vpc_interface_endpoints.id
  description       = var.vpc_egress_interface_endpoint_sg.egress_description
  ip_protocol       = var.vpc_egress_interface_endpoint_sg.ip_protocol
  cidr_ipv4         = var.vpc_egress_interface_endpoint_sg.cidr_ipv4

  tags = {
    Name = "${var.project_settings.project_name}-vpce-egress-all"
  }
}

