output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "igw_id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "ngw_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "public_RT_id" {
  value = aws_route_table.public_route_table.id
}

output "private_RT_id" {
  value = aws_route_table.private_route_table.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}


output "security_group_id" {
  value = aws_security_group.security_group.id
}