resource "aws_db_subnet_group" "this" {
  name       = "${var.project_settings.project_name}-db-subnet"
  subnet_ids = var.private_subnet_ids
}
