resource "aws_lb" "aws_lb" {
  for_each = {
      for lb in local.lbs :
      "${lb.lb_name}" => lb
      if  contains([ lb.env ], "prd" )
  }
  name               = each.value.lb_name
  internal           = each.value.internal
  load_balancer_type = each.value.type
  security_groups    = [ for sg in each.value.security_groups : aws_security_group.aws_security_group["${sg}"].id ]
  subnets            = [ for subnet in each.value.subnets : aws_subnet.aws_subnet[join("_", [each.value.vpc_name, subnet])].id ]

  enable_deletion_protection = false

  tags = {
    Name = "${each.value.lb_name}_${each.value.env}"
  }
}

resource "aws_alb_listener" "aws_alb_listener" {  
  for_each = {
      for lsnr in local.lb_listener :
      "${lsnr.listener_name}" => lsnr
      if  contains([ lsnr.env ], "prd" )
  }
  load_balancer_arn = aws_lb.aws_lb["${each.value.lb}"].arn
  port              = each.value.port
  protocol          = each.value.protocol
  
  default_action {    
    target_group_arn = aws_lb_target_group.aws_lb_target_group["${each.value.tgroup}"].arn
    type             = each.value.tgroup_type
  }

  tags = {
    Name = "${each.value.env}_${each.value.listener_name}"
  }
}


resource "aws_lb_target_group" "aws_lb_target_group" {
  for_each = {
      for tg in local.lb_target_group :
      "${tg.tg_name}" => tg
      if  contains([ tg.env ], "prd" )
  }
  name     = each.value.tg_name
  port     = each.value.port
  protocol = each.value.protocol
  target_type = each.value.target_type
  vpc_id   = aws_vpc.aws_vpc["${each.value.vpc_name}"].id

  health_check {
    enabled = each.value.hc_enabled
    path    = each.value.hc_path
    timeout = each.value.hc_timeout
  }
}
