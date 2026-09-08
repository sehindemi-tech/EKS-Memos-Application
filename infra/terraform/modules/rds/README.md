# rds

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.15.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.62.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.62.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.memo](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/db_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key for encrypting the RDS instance | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs for the EKS cluster and associated resources | `list(string)` | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_rds_instance_settings"></a> [rds\_instance\_settings](#input\_rds\_instance\_settings) | RDS instance configuration | <pre>object({<br/>    allocated_storage           = number<br/>    max_allocated_storage       = number<br/>    allow_major_version_upgrade = bool<br/>    apply_immediately           = bool<br/>    auto_minor_version_upgrade  = bool<br/>    backup_retention_period     = number<br/>    backup_window               = string<br/>    db_name                     = string<br/>    deletion_protection         = bool<br/>    engine                      = string<br/>    username                    = string<br/>    engine_version              = string<br/>    skip_final_snapshot         = bool<br/>    instance_class              = string<br/>    maintenance_window          = string<br/>    manage_master_user_password = bool<br/>    multi_az                    = bool<br/>    publicly_accessible         = bool<br/>    storage_encrypted           = bool<br/>    storage_type                = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | VPC security group IDs for the RDS instance | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_secret_arn"></a> [rds\_secret\_arn](#output\_rds\_secret\_arn) | RDS Secret ARN |
<!-- END_TF_DOCS -->
