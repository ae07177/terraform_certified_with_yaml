resource "aws_security_group" "aws_security_group" {
  for_each = {
      for sg in local.sgroups :
      "${sg.sg_name}" => sg
      if  contains([ sg.env ], "prd" )
  }
  name        = each.value.sg_name
  description = each.value.info
  vpc_id      = aws_vpc.aws_vpc[each.value.vpc_name].id

  dynamic "ingress" {
    for_each = yamldecode(file(each.value.ingress_path))
    content {
      description = each.value.info
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = [ ingress.value.cidr_blocks ]
    }
  }

  dynamic "egress" {
    for_each = yamldecode(file(each.value.egress_path))
    content {
      description = each.value.info
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = [ egress.value.cidr_blocks ]
    }
  }

}
