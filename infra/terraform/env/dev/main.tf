module "route_53" {
  source           = "../../modules/route-53"
  route53_settings = var.route53_settings
}

module "networking" {
  source       = "../../modules/networking"
  vpc_settings = var.vpc_settings

}