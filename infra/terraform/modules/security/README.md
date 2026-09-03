# security

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/kms_key) | resource |
| [aws_security_group.vpc_interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.egress_vpc_endpoints_all](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vpc_ingress_interface_endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.eks_kms_key](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_role_arns"></a> [bootstrap\_role\_arns](#input\_bootstrap\_role\_arns) | IAM roles ARN from bootstrap | `list(string)` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS key for the EKS memo project | <pre>object({<br/>    description             = string<br/>    enable_key_rotation     = bool<br/>    deletion_window_in_days = number<br/>    alias_name              = string<br/>  })</pre> | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block of the VPC | `string` | n/a | yes |
| <a name="input_vpc_egress_interface_endpoint_sg"></a> [vpc\_egress\_interface\_endpoint\_sg](#input\_vpc\_egress\_interface\_endpoint\_sg) | VPC endpoint Security group for EKS memo application | <pre>object({<br/>    egress_description = string<br/>    ip_protocol        = string<br/>    cidr_ipv4          = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |
| <a name="input_vpc_ingress_interface_endpoint_sg"></a> [vpc\_ingress\_interface\_endpoint\_sg](#input\_vpc\_ingress\_interface\_endpoint\_sg) | VPC endpoint Security group for EKS memo application | <pre>object({<br/>    ingress_description = string<br/>    ip_protocol         = string<br/>    from_port           = number<br/>    to_port             = number<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interface_endpoint_sg"></a> [interface\_endpoint\_sg](#output\_interface\_endpoint\_sg) | interface endpoint security group id |
<!-- END_TF_DOCS -->
