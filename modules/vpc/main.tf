locals {
  cluster_name = "opsschool-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


# Create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr_range
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Name                                           = "opsschool-project-vpc"
    "kubernetes.io/cluster/${local.cluster_name}"  = "shared"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name         = "dianatop.com"
  domain_name_servers = ["AmazonProvidedDNS"]

   tags = {
    Name = "dianatop.com"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

# Create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "opsschool-project-igw"
  }
}

# Allocate elastic ip. this eip will be used for the nat-gateway in the public subnet
resource "aws_eip" "eip_nat_gateway" {
  domain = "vpc"

  tags   = {
    Name = "opsschool-project-nat-eip"
  }
}

# Create nat gateway in public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags   = {
    Name = "opsschool-project-nat-gw"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_internet_gateway.internet_gateway]
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available" {
  state = "available"
}


# Create public subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr_range)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_range[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags      = {
    Name                                           = "opsschool-project-public-subnet-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name}"  = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

# create private subnet
resource "aws_subnet" "private_subnet" {
  count                    = length(var.private_subnet_cidr_range)
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_subnet_cidr_range[count.index]
  availability_zone        = data.aws_availability_zones.available.names[count.index % 2]
  map_public_ip_on_launch  = false

  tags      = {
    Name                                          = "opsschool-project-private-subnet-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# create private data subnet
resource "aws_subnet" "private_data_subnet" {
  count                    = length(var.private_data_subnet_cidr_range)
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_data_subnet_cidr_range[count.index % 2]
  availability_zone        = data.aws_availability_zones.available.names[count.index % 2]
  map_public_ip_on_launch  = false

  tags      = {
    Name                                          = "opsschool-project-private-data-subnet-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = var.anyware_cidr_range
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "opsschool-project-public-rt"
  }
}


# associate public subnet to "public route table"
resource "aws_route_table_association" "route_public_subnet_association" {
  count               = length(var.public_subnet_cidr_range)
  subnet_id           = aws_subnet.public_subnet[count.index].id
  route_table_id      = aws_route_table.public_route_table.id
}


# create private route table and add route through nat gateway
resource "aws_route_table" "private_route_table" {
  vpc_id            = aws_vpc.vpc.id

  route {
    cidr_block      = var.anyware_cidr_range
    nat_gateway_id  = aws_nat_gateway.nat_gateway.id
  }

  tags   = {
    Name = "opsschool-project-private-rt"
  }
}

# associate private subnet with private route table
resource "aws_route_table_association" "route_private_subnet_association" {
  count             = length(var.private_subnet_cidr_range)
  subnet_id         = aws_subnet.private_subnet[count.index].id
  route_table_id    = aws_route_table.private_route_table.id
}


# create private data route table and add route through nat gateway
resource "aws_route_table" "private_data_route_table" {
  vpc_id            = aws_vpc.vpc.id

  route {
    cidr_block      = var.anyware_cidr_range
    nat_gateway_id  = aws_nat_gateway.nat_gateway.id
  }

  tags   = {
    Name = "opsschool-project-private-data-rt"
  }
}

# associate private subnet with private route table
resource "aws_route_table_association" "route_private_data_subnet_association" {
  count             = length(var.private_data_subnet_cidr_range)
  subnet_id         = aws_subnet.private_data_subnet[count.index].id
  route_table_id    = aws_route_table.private_data_route_table.id
}
