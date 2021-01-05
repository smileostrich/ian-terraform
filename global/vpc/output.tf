output "aws_vpc_id" {
  description = "vpc id"
  value       = aws_vpc.main.id
}

output "aws_vpc_cidr" {
  description = "vpc cidr block"
  value       = aws_vpc.main.cidr_block
}

output "default_security_group_id" {
  description = "VPC default Security Group ID"
  value       = aws_vpc.main.default_security_group_id
}

output "default_network_acl_id" {
  description = "VPC default network ACL ID"
  value       = aws_vpc.main.default_network_acl_id
}

output "public_subnets" {
  description = "public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "private subnets"
  value       = aws_subnet.private.*.id
}

output "IGW" {
  description = "igw"
  value       = aws_internet_gateway.main.id
}

output "eip" {
  description = "EIP"
  value       = aws_eip.nat.*.id
}

output "nat_gateway" {
  description = "nat gateway"
  value       = aws_nat_gateway.nat.*.id
} 