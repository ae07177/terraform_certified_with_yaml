resource "aws_autoscaling_group" "aws_autoscaling_group" {
  for_each = {
      for asg in local.asgs :
      "${asg.name}" => asg
      if  contains([ asg.env ], "prd" )
  }
  name                      = each.value.name
  depends_on                = [ aws_launch_configuration.aws_launch_configuration ]
  vpc_zone_identifier       = [ for subnet in each.value.vpc_zone_identifier : aws_subnet.aws_subnet[join("_", [each.value.vpc_name, "${subnet}"])].id ]
  max_size                  = each.value.max_size
  min_size                  = each.value.min_size
  health_check_grace_period = each.value.health_check_grace_period
  health_check_type         = each.value.health_check_type
  desired_capacity          = each.value.desired_capacity
  force_delete              = each.value.force_delete
  launch_configuration      = aws_launch_configuration.aws_launch_configuration["${each.value.launch_configuration}"].id
  target_group_arns         = [ for tg in each.value.target_group_arns : aws_lb_target_group.aws_lb_target_group["${tg}"].arn ] 
  tag {
    key                 = "Name"
    value               = "${each.value.env}_${each.value.name}"
    propagate_at_launch = true
  }
}
