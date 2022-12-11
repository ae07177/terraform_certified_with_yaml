locals {
  ##Stores all VPC elements inside "vpcs" variable
  all_data = yamldecode(file("/Users/arvind/terraform_certified_with_yaml/proj1/vars.yaml"))

  ## To be used in vpc.tf
  vpcs = local.all_data.vpc
  
  ## To be used in subnets.tf
  subnets = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.subnet : {
        env               = vpc.env
        subnet_name       = k
        vpc_id            = vpc.name
        cidr_block        = v.cidr_block
        availability_zone = v.availability_zone
        tags              = v.tags
        public            = v.public
      }
    ]
  ])

  ## To be used in internet_gateway.tf
  igw = flatten([
    for vpc in local.vpcs : [ 
      for k, v in vpc.internet_gateway : {
        vpc_id            = vpc.name
        env               = vpc.env
        igw_name          = v.name
        tags              = vpc.tags
        subnet_name       = k
   }]
  ])

  ## To be used in nat_gateway.tf
  ngw = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.nat_gateway : {
        vpc_id            = vpc.name
        env               = vpc.env
        subnet_name       = k
        ngw_name          = v.name
        tags              = vpc.tags
        public            = v.public
        private           = v.private
      }
    ]
  ])

}
