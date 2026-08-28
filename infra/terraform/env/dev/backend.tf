terraform {
  backend "s3" {
    bucket       = "eks-memo-application-eks-441336784821"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}
