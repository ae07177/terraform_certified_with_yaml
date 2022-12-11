locals {
  ##Stores all VPC elements inside "vpcs" variable
  all_data = yamldecode(file("/Users/arvind/terraform-code/functions/vars.yaml"))
}
