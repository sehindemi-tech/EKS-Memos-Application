# networking

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
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_settings"></a> [vpc\_settings](#input\_vpc\_settings) | VPC settings for the EKS Memo platform | <pre>object({<br/>    cidr_block           = optional(string)<br/>    enable_dns_hostnames = optional(bool)<br/>    enable_dns_support   = optional(bool)<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
