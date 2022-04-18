resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_gateway_eip" {
  vpc = true
}


resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.web_subnet["us-east-1c"].id
  allocation_id = aws_eip.nat_gateway_eip.id
}


resource "aws_route_table" "web_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "alloy web route table"
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "alloy app route table"
  }
}

resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "alloy db route table"
  }
}

resource "aws_route" "web_igw_route_ipv4" {
	route_table_id = aws_route_table.web_route_table.id
	gateway_id = aws_internet_gateway.public_igw.id
	destination_cidr_block = "0.0.0.0/0"
	depends_on = [aws_route_table.web_route_table]
}

resource "aws_route_table_association" "web" {
  for_each  = aws_subnet.web_subnet
  subnet_id = aws_subnet.web_subnet[each.key].id
 
  route_table_id = aws_route_table.web_route_table.id
}

resource "aws_route" "app_nat_gw_route_ipv4" {
  route_table_id         = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "app" {
  for_each  = aws_subnet.app_subnet
  subnet_id = aws_subnet.app_subnet[each.key].id
 
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route" "db_nat_gw_route_ipv4" {
  route_table_id         = aws_route_table.db_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "db" {
  for_each  = aws_subnet.db_subnet
  subnet_id = aws_subnet.db_subnet[each.key].id
 
  route_table_id = aws_route_table.db_route_table.id
}

