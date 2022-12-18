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
      description = ingress.value.description
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks =  [ ingress.value.cidr_blocks ]
    }
  }

  dynamic "egress" {
    for_each = yamldecode(file(each.value.egress_path))
    content {
      description = egress.value.description
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = [ egress.value.cidr_blocks ]
    }
  }
}

resource "aws_security_group_rule" "aws_security_group_rule" {
  for_each = {
      for sg in local.sgroup_rule :
      "${sg.description}" => sg
      if  contains([ sg.env ], "prd" )
  }
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.aws_security_group[ each.value.dest_group ].id
  source_security_group_id =  aws_security_group.aws_security_group[ each.value.source_group ].id

  depends_on =  [ aws_security_group.aws_security_group ]
}
