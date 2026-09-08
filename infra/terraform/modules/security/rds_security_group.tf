resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.project_settings.project_name}-rds-sg"
  description = "Allow access to PostgreSQL RDS from within the VPC"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_settings.project_name}-rds-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_from_eks" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.eks_cluster_security_group_id
  description                  = var.rds_sg_ingress_from_eks.ingress_description
  ip_protocol                  = var.rds_sg_ingress_from_eks.ip_protocol
  from_port                    = var.rds_sg_ingress_from_eks.from_port
  to_port                      = var.rds_sg_ingress_from_eks.to_port

  tags = {
    Name = "${var.project_settings.project_name}-rds-ingress"
  }
}

