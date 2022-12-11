resource "aws_internet_gateway" "aws_internet_gateway" {
  for_each = {
    for i in local.igw :
    "${i.vpc_id}:${i.igw_name}" => i
    if  contains([ i.env ], "prd" )
  }
  tags = {
    Name = join("_", [each.value.vpc_id,each.value.igw_name ])
  }
}

resource "aws_internet_gateway_attachment" "aws_internet_gateway_attachment" {
  for_each = {
    for i in local.igw :
    "${i.vpc_id}:${i.igw_name}" => i
    if  contains([ i.env ], "prd" )
  }
  internet_gateway_id = aws_internet_gateway.aws_internet_gateway[join(":", [each.value.vpc_id,each.value.igw_name ])].id
  vpc_id              = aws_vpc.aws_vpc[each.value.vpc_id].id
}

resource "aws_route_table" "internet_gateway" {
  for_each = {
    for i in local.igw :
    "${i.vpc_id}:${i.igw_name}" => i
    if  contains([ i.env ], "prd" )
    }
    vpc_id = aws_vpc.aws_vpc[each.value.vpc_id].id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.aws_internet_gateway["${each.value.vpc_id}:${each.value.igw_name}"].id
    }
  tags = {
    Name = "rt_${each.value.vpc_id}_${each.value.igw_name}" 
  }
}

resource "aws_route" "public_internet_gateway" {
  for_each = {
    for i in local.igw :
    "${i.vpc_id}:${i.igw_name}" => i
    if  contains([ i.env ], "prd" )
    }
  route_table_id         = aws_route_table.internet_gateway["${each.value.vpc_id}:${each.value.igw_name}"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_internet_gateway["${each.value.vpc_id}:${each.value.igw_name}"].id
}


resource "aws_route_table_association" "public" {
  for_each = {
    for i in local.igw :
    "${i.vpc_id}:${i.igw_name}" => i
    if  contains([ i.env ], "prd" )
    }
  subnet_id      = aws_subnet.aws_subnet[join(":", [each.value.vpc_id, each.value.subnet_name ])].id
  route_table_id = aws_route_table.internet_gateway["${each.value.vpc_id}:${each.value.igw_name}"].id
}
