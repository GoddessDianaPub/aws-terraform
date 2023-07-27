output "region" {
   value = var.aws_region
}

output "vpc_id" {
   value = aws_vpc.vpc.id
}

output "igw" {
   value = aws_internet_gateway.internet_gateway
}

output "eip_nat" {
   value = aws_eip.eip_nat_gateway
}

output "nat_gw" {
   value = aws_eip.eip_nat_gateway
}

output "availability_zones_names" {
   value = data.aws_availability_zones.available.names.*
}

output "public_subnet_id" {
   value = aws_subnet.public_subnet.*.id
}

output "private_subnet_id" {
   value = aws_subnet.private_subnet.*.id
}
 
output "private_data_subnet_id" {
   value = aws_subnet.private_data_subnet.*.id
}

output "cluster_name" {
  value = local.cluster_name
}


