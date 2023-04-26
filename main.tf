################################################################################
# Networking related resources calling its module
################################################################################

module "networking" {
  source = "./modules/networking"
  region = var.region
  azs    = var.azs
  cidr   = var.cidr
}

################################################################################
# Web layer related resources calling its module (ALB, EC2, ASG, etc)
################################################################################

module "web_layer" {
  source          = "./modules/web"
  image_id        = var.image_id
  subnet_ids      = module.networking.vpc.public_subnets.ids
  vpc_id          = module.networking.vpc.id
  web_name_prefix = var.web_name_prefix
  my_ip_address   = var.my_ip_address

  depends_on = [module.networking]
}

################################################################################
# RDS related resources calling its module
################################################################################

module "rds_db" {
  source                  = "./modules/rds"
  autoscaling_group_sg_id = module.web_layer.aws_asg_sg_id
  db_name                 = var.db_name
  rds_name_prefix         = var.rds_name_prefix
  subnet_ids              = module.networking.vpc.private_subnets.ids
  username                = var.username
  vpc_id                  = module.networking.vpc.id

  depends_on = [module.networking]
}
