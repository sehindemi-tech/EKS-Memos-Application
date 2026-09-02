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
| <a name="module_networking"></a> [networking](#module\_networking) | ../../modules/networking | n/a |
| <a name="module_route_53"></a> [route\_53](#module\_route\_53) | ../../modules/route-53 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_route53_settings"></a> [route53\_settings](#input\_route53\_settings) | Route 53 Zone for EKS Memo Application | <pre>object({<br/>    name          = string<br/>    force_destroy = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_settings"></a> [vpc\_settings](#input\_vpc\_settings) | VPC settings for the EKS Memo platform | <pre>object({<br/>    cidr_block           = optional(string)<br/>    enable_dns_hostnames = optional(bool)<br/>    enable_dns_support   = optional(bool)<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
