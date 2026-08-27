# bootstrap

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
| [aws_s3_bucket.states](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.states_blocking](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state_sse](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.states_versioning](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/6.62.0/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_settings"></a> [project\_settings](#input\_project\_settings) | The Default setting for our EKS Memo Project | <pre>object({<br/>    aws_region   = optional(string, "eu-west-2")<br/>    org          = optional(string, "sehindemi-tech")<br/>    github_repo  = optional(string, "eks-memos-application")<br/>    project_name = optional(string, "eks-memos-application")<br/>  })</pre> | `{}` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | S3 Bucket settings | <pre>object({<br/>    bucket_settings = map(object({<br/>      name          = string<br/>      force_destroy = optional(bool, false)<br/>      description   = optional(string)<br/>      versioning    = optional(bool, true)<br/>      sse_algorithm = optional(string, "AES256")<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
