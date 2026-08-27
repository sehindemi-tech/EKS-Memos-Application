plugin "aws" {
  enabled = true
  region = "eu-west-2"
  version = "0.47.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  deep_check = false
}

plugin "terraform" {
  enabled = true
  version = "0.15.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

tflint {
  required_version = "0.63.1"
}

rule "terraform_standard_module_structure" {
  enabled = false
}
