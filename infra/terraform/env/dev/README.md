# dev

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.15.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.62.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | ../../modules/eks | n/a |
| <a name="module_logging"></a> [logging](#module\_logging) | ../../modules/logging | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ../../modules/networking | n/a |
| <a name="module_route_53"></a> [route\_53](#module\_route\_53) | ../../modules/route-53 | n/a |
| <a name="module_security"></a> [security](#module\_security) | ../../modules/security | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_role_arns"></a> [bootstrap\_role\_arns](#input\_bootstrap\_role\_arns) | IAM roles ARN from bootstrap | `list(string)` | n/a | yes |
| <a name="input_cloud_watch"></a> [cloud\_watch](#input\_cloud\_watch) | CloudWatch log group settings | <pre>object({<br/>    name              = string<br/>    log_group_class   = string<br/>    retention_in_days = number<br/>  })</pre> | n/a | yes |
| <a name="input_eip_domain"></a> [eip\_domain](#input\_eip\_domain) | VPC domain configuration for Elastic IP | `string` | n/a | yes |
| <a name="input_eks_cluster_settings"></a> [eks\_cluster\_settings](#input\_eks\_cluster\_settings) | EKS cluster settings for the EKS memo Application | <pre>object({<br/>    version                       = string<br/>    deletion_protection           = bool<br/>    enabled_cluster_log_type      = list(string)<br/>    bootstrap_self_managed_addons = bool<br/>    endpoint_public_access        = bool<br/>    endpoint_private_access       = bool<br/>    public_access_cidrs           = list(string)<br/>    access_config = object({<br/>      authentication_mode                         = string<br/>      bootstrap_cluster_creator_admin_permissions = bool<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_eks_node_managed_policy_arns"></a> [eks\_node\_managed\_policy\_arns](#input\_eks\_node\_managed\_policy\_arns) | Managed IAM policy ARNs to attach to the EKS node group role | `list(string)` | n/a | yes |
| <a name="input_gateway_endpoint_settings"></a> [gateway\_endpoint\_settings](#input\_gateway\_endpoint\_settings) | AWS service names for Gateway VPC endpoints (S3, DynamoDB) | `set(string)` | n/a | yes |
| <a name="input_interface_endpoint_settings"></a> [interface\_endpoint\_settings](#input\_interface\_endpoint\_settings) | AWS service names for Interface VPC endpoints | `set(string)` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS key for the EKS memo project | <pre>object({<br/>    description             = string<br/>    enable_key_rotation     = bool<br/>    deletion_window_in_days = number<br/>    alias_name              = string<br/>  })</pre> | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_route53_settings"></a> [route53\_settings](#input\_route53\_settings) | Route 53 Zone for EKS Memo Application | <pre>object({<br/>    name          = string<br/>    force_destroy = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_subnet_settings"></a> [subnet\_settings](#input\_subnet\_settings) | Public & private VPC subnet definitions; is\_public drives public IP assignment | <pre>map(object({<br/>    availability_zone       = optional(string)<br/>    cidr_block              = optional(string)<br/>    map_public_ip_on_launch = optional(bool)<br/>    is_public               = optional(bool)<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_egress_interface_endpoint_sg"></a> [vpc\_egress\_interface\_endpoint\_sg](#input\_vpc\_egress\_interface\_endpoint\_sg) | VPC endpoint Security group for EKS memo application | <pre>object({<br/>    egress_description = string<br/>    ip_protocol        = string<br/>    cidr_ipv4          = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_ingress_interface_endpoint_sg"></a> [vpc\_ingress\_interface\_endpoint\_sg](#input\_vpc\_ingress\_interface\_endpoint\_sg) | VPC endpoint Security group for EKS memo application | <pre>object({<br/>    ingress_description = string<br/>    ip_protocol         = string<br/>    from_port           = number<br/>    to_port             = number<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_settings"></a> [vpc\_settings](#input\_vpc\_settings) | VPC settings for the EKS Memo platform | <pre>object({<br/>    cidr_block           = optional(string)<br/>    enable_dns_hostnames = optional(bool)<br/>    enable_dns_support   = optional(bool)<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
