resource "aws_route_table" "aws_route_table" {
  for_each = {
    for n in local.rtb :
    "${n.vpc_name}_${n.subnet_name}_${n.gw}" => n
    if  contains([ n.env ], "prd" )
    }
    vpc_id = aws_vpc.aws_vpc[each.value.vpc_name].id
  tags = {
    Name = "rt_${each.value.vpc_name}_${each.value.subnet_name}_${each.value.gw}"
  }
}


resource "aws_route" "aws_route" {
  for_each = {
    for n in local.rtb :
    "${n.vpc_name}_${n.subnet_name}_${n.gw}" => n
    if  contains([ n.env ], "prd" )
    }
  route_table_id         = aws_route_table.aws_route_table["${each.value.vpc_name}_${each.value.subnet_name}_${each.value.gw}"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = each.value.public ? aws_internet_gateway.aws_internet_gateway["${each.value.vpc_name}_${each.value.gw}"].id : aws_nat_gateway.aws_nat_gateway["${each.value.vpc_name}_${each.value.subnet_name}_${each.value.gw}"].id
}

resource "aws_route_table_association" "aws_route_table_association" {
  for_each = {
    for n in local.rtb :
    "${n.vpc_name}_${n.subnet_name}_${n.gw}" => n
    if  contains([ n.env ], "prd" )
    }
  subnet_id      = aws_subnet.aws_subnet[join("_", [each.value.vpc_name, each.value.subnet_name ])].id
  #route_table_id = each.value.public ? aws_route_table.internet_gateway["${each.value.vpc_name}_${each.value.gw}"].id : aws_route_table.nat_gateway["${each.value.vpc_name}_${each.value.subnet_name}_${each.value.gw}"].id
  route_table_id = aws_route_table.aws_route_table["${each.value.vpc_name}_${each.value.subnet_name}_${each.value.gw}"].id
}
