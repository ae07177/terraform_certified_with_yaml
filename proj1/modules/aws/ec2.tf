data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#resource "aws_instance" "aws_instance" {
#  for_each = {
#      for ec2 in local.ec2 :
#      "${ec2.instance_name}" => ec2
#      if  contains([ ec2.env ], "prd" )
#  }
#        ami                    = data.aws_ssm_parameter.ami_id.value
#        subnet_id              = aws_subnet.aws_subnet[join(":", [each.value.vpc_name, each.value.subnet_name ])].id
#        instance_type          = each.value.type
#        vpc_security_group_ids = split(",", aws_security_group.aws_security_group[each.value.sgs].id)
#        user_data              = fileexists(each.value.user_data) ? file(each.value.user_data) : null
#        associate_public_ip_address = each.value.public ? true : false
#        key_name               = aws_key_pair.aws_key_pair[each.value.key_name].key_name
#        tags                   = {
#          Name =  each.key
#        }
#}

resource "aws_launch_configuration" "aws_launch_configuration" {
  for_each = {
      for ec2 in local.ec2 : 
      "${ec2.instance_name}" => ec2
      if  contains([ ec2.env ], "prd" )
  }
  name                        = "${each.value.env}_${each.value.instance_name}"
  image_id                    = data.aws_ssm_parameter.ami_id.value
  instance_type               = each.value.type
  key_name                    = aws_key_pair.aws_key_pair[each.value.key_name].key_name
  security_groups             = split(",", aws_security_group.aws_security_group[each.value.sgs].id)
  user_data                   = fileexists(each.value.user_data) ? file(each.value.user_data) : null
  associate_public_ip_address = true
}
