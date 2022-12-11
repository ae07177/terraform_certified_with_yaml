#locals {
#  vpcs = local.all_data.vpc
#}

#output "vpcs" {
#  value = local.vpcs
#}

#resource "null_resource" "vpcs" {
#  ###This for_each returns the env value for each vpc element
#  for_each = { for k, v in local.vpcs[*].tags : k => v }
#  triggers = {
#    name = each.value
#  }
#}

resource "aws_vpc" "aws_vpc" {
  for_each = {
    for element in local.vpcs : element.name => element
    if  contains([ element.env ], "prd" )
  }
  cidr_block = each.value.cidr_block
  tags = each.value.tags
}

