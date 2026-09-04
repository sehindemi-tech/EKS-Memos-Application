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
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/eks_node_group) | resource |
| [aws_iam_role.eks_node_iam_role](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.node_policy_arns](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.eks_node_assume_role](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_kms_key"></a> [eks\_cluster\_kms\_key](#input\_eks\_cluster\_kms\_key) | The ARN of the KMS key for the EKS cluster encryption | `string` | n/a | yes |
| <a name="input_eks_cluster_settings"></a> [eks\_cluster\_settings](#input\_eks\_cluster\_settings) | EKS cluster settings for the EKS memo Application | <pre>object({<br/>    version                       = string<br/>    deletion_protection           = bool<br/>    enabled_cluster_log_type      = list(string)<br/>    bootstrap_self_managed_addons = bool<br/>    endpoint_public_access        = bool<br/>    endpoint_private_access       = bool<br/>    public_access_cidrs           = list(string)<br/>    access_config = object({<br/>      authentication_mode                         = string<br/>      bootstrap_cluster_creator_admin_permissions = bool<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_eks_node_group_settings"></a> [eks\_node\_group\_settings](#input\_eks\_node\_group\_settings) | EKS node group settings | <pre>object({<br/>    instance_type = list(string)<br/>    capacity_type = string<br/>    ami_type      = string<br/>    disk_size     = number<br/>    scaling_config = object({<br/>      min_size     = number<br/>      max_size     = number<br/>      desired_size = number<br/>    })<br/>    update_config = object({<br/>      max_unavailable = number<br/>      update_strategy = string<br/>    })<br/><br/>  })</pre> | n/a | yes |
| <a name="input_eks_node_managed_policy_arns"></a> [eks\_node\_managed\_policy\_arns](#input\_eks\_node\_managed\_policy\_arns) | Managed IAM policy ARNs to attach to the EKS node group role | `set(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private Subnet ids | `list(string)` | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet EKS ENI will be in | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
