module "route_53" {
  source           = "../../modules/route-53"
  route53_settings = var.route53_settings
}

module "networking" {
  source               = "../../modules/networking"
  vpc_settings         = var.vpc_settings
  subnet_settings      = var.subnet_settings
  eip_domain           = var.eip_domain
  project_settings     = var.project_settings
  nat_gateway_settings = var.nat_gateway_settings

}