##################
# Local Variable #
##################
locals {
  region       = "ap-northeast-2"
}

#######
# VPC #
#######
module "vpc" {
  source = "github.com/smileostrich/ian-terraform/tree/main/global/vpc"
  aws_vpc_name        = "stg-apne2"
  aws_vpc_cidr        = "10.0.0.0/16"
  aws_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  aws_private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  aws_region          = local.region
  aws_azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  
  global_tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

