
resource "aws_nat_gateway" "aws_nat_gateway" {
  for_each = {
    for n in  local.ngw :
    "${n.vpc_id}_${n.subnet_name}_${n.ngw_name}" => n
    if  contains([ n.env ], "prd" ) && contains([ n.private ], true ) && local.subnets != null &&  local.ngw != null

  }

  allocation_id = aws_eip.aws_nat_gateway[join("_", ["${each.value.vpc_id}", "${each.value.subnet_name}_${each.value.ngw_name}" ])].id
  subnet_id     = aws_subnet.aws_subnet[join("_", [each.value.vpc_id, each.value.subnet_name ])].id
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
