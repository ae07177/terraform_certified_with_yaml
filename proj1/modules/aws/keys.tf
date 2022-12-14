resource "aws_key_pair" "aws_key_pair" {
  for_each = {
      for key in local.pub_key :
      "${key.key_name}" => key
      if  contains([ key.env ], "prd" )
    }

  key_name   = each.value.key_name
  public_key = each.value.public_key
}
