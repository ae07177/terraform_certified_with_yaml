
resource "aws_internet_gateway" "aws_internet_gateway" {
  for_each = {
    for n in  local.igw :
    "${n.vpc_id}_${n.igw_name}" => n
    if  contains([ n.env ], "prd" ) && local.igw != null
  }
  vpc_id = aws_vpc.aws_vpc["${each.value.vpc_id}"].id
  tags   =  {
    Name = "${each.value.vpc_id}_${each.value.igw_name}"
  }
}

resource "aws_route_table" "internet_gateway" {
  for_each = {
    for n in local.igw :
    "${n.vpc_id}_${n.igw_name}" => n
    if  contains([ n.env ], "prd" ) &&  local.igw != null
    }
    vpc_id = aws_vpc.aws_vpc[each.value.vpc_id].id
  tags = {
    Name = "rt_${each.value.vpc_id}_${each.value.igw_name}"
  }
}


resource "aws_route" "public_internet_gateway" {
  for_each = {
    for n in local.igw :
    "${n.vpc_id}_${n.igw_name}" => n
    if  contains([ n.env ], "prd" )  &&  local.igw != null
    }
  route_table_id         = aws_route_table.internet_gateway["${each.value.vpc_id}_${each.value.igw_name}"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_internet_gateway["${each.value.vpc_id}_${each.value.igw_name}"].id
}


resource "aws_route_table_association" "public" {
  for_each = {
    for s in local.subnets :
    "${s.vpc_id}_${s.subnet_name}_${s.gw}" => s
    if  contains([ s.env ], "prd" ) && local.subnets != null && contains([ s.public ], true )
  }
  subnet_id      = aws_subnet.aws_subnet["${each.value.vpc_id}_${each.value.subnet_name}"].id
  route_table_id = aws_route_table.internet_gateway["${each.value.vpc_id}_${each.value.gw}"].id
}
