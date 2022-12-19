
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
