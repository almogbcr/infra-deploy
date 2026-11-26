module "dev" {
  source         = "./modules/network"
  vpc_cidr       = var.dev.vpc_cidr
  env            = var.dev.env
  subnet_private = var.dev.subnet_private
  subnet_public  = var.dev.subnet_public
}

module "prod" {
  source         = "./modules/network"
  vpc_cidr       = var.prod.vpc_cidr
  env            = var.prod.env
  subnet_private = var.prod.subnet_private
  subnet_public  = var.prod.subnet_public
}