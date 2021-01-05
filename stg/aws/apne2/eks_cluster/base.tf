# # terraform tutorial + 서적(terraform up & running) + 강의 참고
terraform {
  required_version = ">= 0.14.3, <0.15"
  
  backend "remote" {
    organization = "ian"
    workspaces {
        name = "ian-terraform-vpc"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.10"
    }
  }
}
provider "aws" {
  region  = "ap-northeast-2" 
}


# # mutiple provider 구성 시 아래 참조.
# # https://www.terraform.io/docs/configuration/providers.html#alias-multiple-provider-configurations