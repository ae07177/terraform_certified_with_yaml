#locals {
#  user_list = {user="John", group="admin"}
#}
#
#resource "null_resource" "foo" {
#  for_each = { for k,v in local.user_list : k => v }
#  provisioner "local-exec" {
#    command = "echo ${each.key} is ${each.value}"
#  }
#}
#
#output "user_list" {
#  value = null_resource.foo
#}


locals {
  pol_grp = {
    a = { pol1 = "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
          pol2 = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess" }
    b = { pol1 = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" }
  }
  pol_arns_list= toset(flatten([
    for group in local.pol_grp : [
      for arn in group:
      arn ] ]))
  pols = tomap({
    for gk, group in local.pol_grp : gk => tomap({
      for pk, arn in group : pk => {
        arn    = arn } }) })
}
output "pol_grp" { value = local.pol_grp }
output "pol_arns_list" { value = local.pol_arns_list }
output "pols" { value = local.pols }
