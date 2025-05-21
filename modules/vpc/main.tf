data "aws_region" "current" {} # Fetching current region
data "aws_availability_zones" "available" {} # Fetching AZs

# *** VPC ***
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment}-${var.vpc_name}-${data.aws_region.current.name}"
  }
}

# *** Internet Gateway ***
resource "aws_internet_gateway" "internet_gateway" {
  tags = {
    Name = "${var.environment}-${var.igw_name}-${data.aws_region.current.name}"
  }
}

# *** VPC Attachment ***
resource "aws_internet_gateway_attachment" "igw_vpc_attachment" {
  vpc_id = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
}

# *** Elastic IP Address ***
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-${var.eip_name}-${data.aws_region.current.name}"
  }
}

# *** NAT Gateway ***
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.elastic_ip.allocation_id
  tags = {
    Name = "${var.environment}-${var.ngw_name}-${data.aws_region.current.name}"
  }
}

# *** Public Route Table ***
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-${var.public_RT_name}-${data.aws_region.current.name}"
  }
}

# *** Public Route ***
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

# *** Private Route Table ***
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-${var.private_RT_name}-${data.aws_region.current.name}"
  }
}

# *** Private Route ***
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway.id
}

# *** Public Subnets ***
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(
    var.vpc_cidr, 
    var.subnet_mask, 
    count.index
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.public_subnet_name}-${count.index+1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# *** Public Subnet Route Table Association ***
resource "aws_route_table_association" "public_subnet_RT_association" {
  count = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public_subnets[count.index].id
}

# *** Private Subnets ***
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(
    var.vpc_cidr, 
    var.subnet_mask, 
    count.index + length(data.aws_availability_zones.available.names)
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-${var.private_subnet_name}-${count.index+1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# *** Private Subnet Route Table Association ***
resource "aws_route_table_association" "private_subnet_RT_association" {
  count = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.private_subnets[count.index].id
}

# *** Security Group ***
resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  description = "Allow HTTP and MySQL Access"
  tags = {
    Name = "${var.environment}-${var.sg_name}-${data.aws_region.current.name}"
  }
}

# *** Security Group Outbound Rule ***
resource "aws_vpc_security_group_egress_rule" "allow_outbound_traffic" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol = "-1"
  from_port   = 0
  to_port     = 0
  cidr_ipv4 = "0.0.0.0/0"
}

# *** Security Group Inbound Rule : HTTP  ***
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}

# *** Security Group Inbound Rule : MySQL ***
resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol = "tcp"
  from_port = 3306
  to_port = 3306
  cidr_ipv4 = aws_vpc.vpc.cidr_block
}