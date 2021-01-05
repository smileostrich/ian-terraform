# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = merge(var.tags,
  {
    "Name" = format("%s", var.aws_vpc_name)
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags,
  {
    "Name" = format("%s", var.aws_vpc_name)
  })
}

# default network ACL
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = concat(
    aws_subnet.public[*].id,
    aws_subnet.private[*].id,
    # aws_subnet.database[*].id,
  )


  tags = merge(var.tags, map("Name", format("%s-default", var.aws_vpc_name)))
}

# default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-default", var.aws_vpc_name)))
}


# Setting Subnet
# Create Public Subnet
resource "aws_subnet" "public" {
  count             = length(var.aws_public_subnets)
  cidr_block        = var.aws_public_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  # EKS node group에 자동으로 IP 할당을 해주기위함.
  # map_public_ip_on_launch = true

  availability_zone = var.aws_azs[count.index]
  tags = merge(var.tags,
  {
    "Name" = format("%s-%s", var.aws_vpc_name, "EKS-PUBLIC${count.index}")
    # "kubernetes.io/role/elb"= 1
  })
}

# Private Subnet
resource "aws_subnet" "PR-TEST-PRISUB" {
  count             = length(var.aws_private_subnets)
  cidr_block        = var.aws_private_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = var.aws_azs[count.index]
  tags = merge(var.tags,
  {
    "Name" = format("%s-%s", var.aws_vpc_name, "EKS-PRIVATE${count.index}")
    # "kubernetes.io/role/internal-elb"= 1
  })
}


#
# EIP for Nat Gateway
resource "aws_eip" "nat" {
  vpc   = true
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.0.id

  tags = merge(var.tags,
  {
    "Name" = format("%s-%s", var.aws_vpc_name, "EKS-NATGW")
  })
}



## Route Table
# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags,
  {
    "Name" = format("%s-%s", var.aws_vpc_name, "EKS-PUBLIC-ROUTE")
  })
}
# Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.tags,
  {
    "Name" = format("%s-%s", var.aws_vpc_name, "EKS-PRIVATE-ROUTE")
  })
}


## Route Table Routing
# Create Public Route Table Routing
resource "aws_route_table_association" "public" {
  count = length(var.aws_public_subnets)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.*.id[count.index]
}
# Create Private Route Table Routing
resource "aws_route_table_association" "private" {
  count = length(var.aws_private_subnets)

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.*.id[count.index]
}