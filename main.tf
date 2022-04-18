
module "alloy_networking" {
  source   = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "alloy_iam" {
  source = "./modules/iam"

  db_secret_arn = module.alloy_rds.db_secret_arn
}

module "alloy_alb" {
  source = "./modules/alb"

  web_sg      = module.alloy_networking.web_sg_id
  web_subnets = module.alloy_networking.web_subnets_id
  vpc_id      = module.alloy_networking.vpc_id

}

module "alloy_asg" {
  source = "./modules/asg"

  ec2_instance_profile_name = module.alloy_iam.ec2_instance_profile_name
  app_sg                    = module.alloy_networking.app_sg_id
  app_subnets               = module.alloy_networking.app_subnets_id
  alb_target_group_arn      = module.alloy_alb.alb_target_group_arn
}

module "alloy_rds" {
  source = "./modules/rds"

  db_subnets_id = module.alloy_networking.db_subnets_id
  db_sg_id      = module.alloy_networking.db_sg_id

}

