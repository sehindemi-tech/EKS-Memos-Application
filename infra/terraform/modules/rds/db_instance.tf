resource "aws_db_instance" "memo" {
  identifier                  = "${var.project_settings.project_name}-db"
  allow_major_version_upgrade = var.rds_instance_settings.allow_major_version_upgrade
  engine                      = var.rds_instance_settings.engine
  instance_class              = var.rds_instance_settings.instance_class
  allocated_storage           = var.rds_instance_settings.allocated_storage
  max_allocated_storage       = var.rds_instance_settings.max_allocated_storage
  storage_type                = var.rds_instance_settings.storage_type
  storage_encrypted           = var.rds_instance_settings.storage_encrypted
  maintenance_window          = var.rds_instance_settings.maintenance_window
  kms_key_id                  = var.kms_key_id
  manage_master_user_password = var.rds_instance_settings.manage_master_user_password
  apply_immediately           = var.rds_instance_settings.apply_immediately
  auto_minor_version_upgrade  = var.rds_instance_settings.auto_minor_version_upgrade
  engine_version              = var.rds_instance_settings.engine_version
  backup_window               = var.rds_instance_settings.backup_window
  final_snapshot_identifier   = "${var.project_settings.project_name}-db-final"

  db_name  = var.rds_instance_settings.db_name
  username = var.rds_instance_settings.username

  master_user_secret_kms_key_id = var.kms_key_id

  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  publicly_accessible     = var.rds_instance_settings.publicly_accessible
  multi_az                = var.rds_instance_settings.multi_az
  backup_retention_period = var.rds_instance_settings.backup_retention_period
  skip_final_snapshot     = var.rds_instance_settings.skip_final_snapshot

  deletion_protection = var.rds_instance_settings.deletion_protection

  tags = {
    Name = "${var.project_settings.project_name}-postgres"
  }
}


