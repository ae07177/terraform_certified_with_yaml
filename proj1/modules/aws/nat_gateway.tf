
resource "aws_nat_gateway" "aws_nat_gateway" {
  for_each = {
    for n in  local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null

  }

  allocation_id = aws_eip.aws_nat_gateway[join("_", ["${each.value.vpc_id}", "${each.value.subnet_name}_${each.value.ngw_name}" ])].id
#  allocation_id = aws_eip.aws_nat_gateway.id
  subnet_id     = aws_subnet.aws_subnet[join("_", [each.value.vpc_id, each.value.subnet_name ])].id
#  subnet_id     = aws_subnet.aws_subnet[each.value.subnet_id].id
  tags   =  {
    Name = join("_", [each.value.vpc_id, each.value.subnet_name ])
  }

}

resource "aws_eip" "aws_nat_gateway" {
  for_each = {
    for n in  local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null
  }
  vpc = true
}

resource "aws_route_table" "nat_gateway" {
  for_each = {
    for n in local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null
    }
    vpc_id = aws_vpc.aws_vpc[each.value.vpc_id].id
  tags = {
    Name = "rt_${each.value.vpc_id}_${each.value.subnet_name}_${each.value.ngw_name}"
  }
}


resource "aws_route" "private_nat_gateway" {
  for_each = {
    for n in local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null
    }
  route_table_id         = aws_route_table.nat_gateway["${each.value.vpc_id}_${each.value.subnet_name}_${each.value.ngw_name}"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.aws_nat_gateway["${each.value.vpc_id}_${each.value.subnet_name}_${each.value.ngw_name}"].id
}


resource "aws_route_table_association" "private" {
  for_each = {
    for n in local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null
    }
  subnet_id      = aws_subnet.aws_subnet[join("_", [each.value.vpc_id, each.value.subnet_name ])].id
  route_table_id = aws_route_table.nat_gateway["${each.value.vpc_id}_${each.value.subnet_name}_${each.value.ngw_name}"].id
}
