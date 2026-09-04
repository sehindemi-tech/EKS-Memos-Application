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
  kms_key                           = var.kms_key
  bootstrap_role_arns               = var.bootstrap_role_arns
}

module "logging" {
  source      = "../../modules/logging"
  cloud_watch = var.cloud_watch
  vpc_id      = module.networking.vpc_id
}
module "eks" {
  source                       = "../../modules/eks"
  eks_cluster_settings         = var.eks_cluster_settings
  subnet_ids                   = module.networking.subnet_ids
  eks_cluster_kms_key          = module.security.eks_cluster_kms_key
  eks_node_managed_policy_arns = var.eks_node_managed_policy_arns
  private_subnet_ids           = module.networking.private_subnet_ids
  eks_node_group_settings      = var.eks_node_group_settings
}