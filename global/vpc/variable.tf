variable "aws_vpc_name" {
  description = "리소스에 붙을 고유한 name"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "vpc에 할당한 CIDR Block"
  type        = string
}

variable "aws_public_subnets" {
  description = "public subnet"
  type        = list(string)
}

variable "aws_private_subnets" {
  description = "Private Subnet"
  type        = list(string)
}

variable "aws_region" {
  description = "region"
  type        = string
}

variable "aws_azs" {
  description = "availability zones"
  type        = list(string)
}

# Naming
variable "tags" {
  description = "tag map for all resouce"
  type        = map(string)
}

