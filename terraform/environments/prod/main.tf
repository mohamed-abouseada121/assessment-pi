terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "security" {
  source           = "../../modules/security"
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  tags             = var.tags
}

module "ecr" {
  count        = var.enable_ecr ? 1 : 0
  source       = "../../modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  environment           = var.environment
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  instance_class        = var.db_instance_class
  tags                  = var.tags
}

module "ec2" {
  source                = "../../modules/ec2"
  project_name          = var.project_name
  environment           = var.environment
  subnet_id             = module.vpc.public_subnet_ids[0]
  ec2_security_group_id = module.security.ec2_security_group_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  public_key            = var.public_key
  tags                  = var.tags
}

module "monitoring" {
  source       = "../../modules/monitoring"
  project_name = var.project_name
  environment  = var.environment
  instance_id  = module.ec2.instance_id
  tags         = var.tags
}
