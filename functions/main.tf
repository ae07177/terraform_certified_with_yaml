#locals {
#  name = 1
#}
#
#variable in {
#  default = 2
#}


output "vpcs" {
  value = local.std_vpcs
}

resource "null_resource" "vpcs" {
  ###This for_each returns the env value for each vpc element
  for_each = { for k, v in local.vpcs[*].env : k => v }
  triggers = {
    name = each.value
  }
}
