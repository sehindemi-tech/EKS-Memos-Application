module "route_53" {
  source           = "../../modules/route-53"
  route53_settings = var.route53_settings
}

module "networking" {
  source                      = "../../modules/networking"
  vpc_settings                = var.vpc_settings
  subnet_settings             = var.subnet_settings
  eip_domain                  = var.eip_domain
  project_settings            = var.project_settings
  interface_endpoint_settings = var.interface_endpoint_settings
  gateway_endpoint_settings   = var.gateway_endpoint_settings
  interface_endpoint_sg_id    = module.security.interface_endpoint_sg
}

module "security" {
  source                            = "../../modules/security"
  project_settings                  = var.project_settings
  vpc_cidr                          = module.networking.vpc_cidr
  vpc_ingress_interface_endpoint_sg = var.vpc_ingress_interface_endpoint_sg
  vpc_egress_interface_endpoint_sg  = var.vpc_egress_interface_endpoint_sg
  vpc_id                            = module.networking.vpc_id

}