# eks

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
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/eks_cluster) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_kms_key"></a> [eks\_cluster\_kms\_key](#input\_eks\_cluster\_kms\_key) | The ARN of the KMS key for the EKS cluster encryption | `string` | n/a | yes |
| <a name="input_eks_cluster_settings"></a> [eks\_cluster\_settings](#input\_eks\_cluster\_settings) | EKS cluster settings for the EKS memo Application | <pre>object({<br/>    version                       = string<br/>    deletion_protection           = bool<br/>    enabled_cluster_log_type      = list(string)<br/>    bootstrap_self_managed_addons = bool<br/>    endpoint_public_access        = bool<br/>    endpoint_private_access       = bool<br/>    public_access_cidrs           = list(string)<br/>    access_config = object({<br/>      authentication_mode                         = string<br/>      bootstrap_cluster_creator_admin_permissions = bool<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet EKS ENI will be in | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
