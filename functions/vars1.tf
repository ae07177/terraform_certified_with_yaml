locals {
  vpcs = local.all_data.vpc
  ###Below flattens the vpcs tuple with vpc details 
  std_vpcs = flatten([for vpc in local.vpcs:
    {
     "name" = "${vpc.env}-${vpc.name}"
     ###Since Subnet Range is a List Param, we are using for loop again
     "subnets" = flatten([for subnet in vpc.subnet:
       {
       #### lookup("variable_in_for_loop", "variable_in_var_file", "default_value") 
       "subnet_name" = lookup(subnet,"name",null)
       "subnet_range" = lookup(subnet,"range","10.0.0.0/24")
       }
     ])
    }
    ### Creates Vars if "prd" is present in tags
    if  contains(vpc.tags, "prd" )
  ])
}
