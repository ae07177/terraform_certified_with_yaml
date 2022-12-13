resource "aws_subnet" "aws_subnet" {
  for_each = {
    for s in local.subnets :
    "${s.vpc_id}:${s.subnet_name}" => s
    if  contains([ s.env ], "prd" ) && local.subnets != null
  }

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  vpc_id            = aws_vpc.aws_vpc[each.value.vpc_id].id
  tags              = each.value.tags

  map_public_ip_on_launch = false
}
