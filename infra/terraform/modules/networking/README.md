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
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eip_domain"></a> [eip\_domain](#input\_eip\_domain) | VPC domain configuration for Elastic IP | `string` | n/a | yes |
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_subnet_settings"></a> [subnet\_settings](#input\_subnet\_settings) | Details about the Public & Private vpc subnets | <pre>map(object({<br/>    availability_zone       = optional(string)<br/>    cidr_block              = optional(string)<br/>    map_public_ip_on_launch = optional(bool)<br/>    is_public               = optional(bool)<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_settings"></a> [vpc\_settings](#input\_vpc\_settings) | VPC settings for the EKS Memo platform | <pre>object({<br/>    cidr_block           = optional(string)<br/>    enable_dns_hostnames = optional(bool)<br/>    enable_dns_support   = optional(bool)<br/>    vpc_name             = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
