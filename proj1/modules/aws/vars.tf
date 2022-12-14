variable "yaml_file" {
  type        = string
  description = "file location for yaml config data"
  #default     = "/Users/arvind/terraform_certified_with_yaml/proj1/vars.yaml"
  default     = null
}

locals {
  ##Stores all VPC elements inside "vpcs" variable
  all_data = yamldecode(file("${var.yaml_file}"))

  ## To be used in vpc.tf
  vpcs = local.all_data.vpc
  
  ## To be used in subnets.tf
  subnets = flatten([
    for vpc in local.vpcs : [
      for k, v in ( vpc.subnet == null ? {} : vpc.subnet ) : {
        env               = vpc.env == null ? "dev" : vpc.env
        subnet_name       = k == null ? "" : k
        vpc_id            = vpc.name == null ? "" : vpc.name
        cidr_block        = v.cidr_block == null ? "" : v.cidr_block
        availability_zone = v.availability_zone == null ? "" : v.availability_zone
        tags              = v.tags == null ? {} : v.tags
        public            = v.public == null ? true : false
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

  ## Extract Public Key
  pub_key = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.public_key : {
         env        = vpc.env
         key_name   = k
         public_key = file(v.path)
      }
    ]
  ])

  ## To be used in nat_gateway.tf
  ec2 = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.instances : {
        vpc_name          = vpc.name
        env               = vpc.env
        instance_name     = k
        subnet_name       = v.subnet
        type              = v.type
        user_data         = v.user_data
        sgs               = v.sgs
        key_name          = v.key_name
        public            = v.public
      }
    ]
  ])

  sgroups = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.security_groups : {
          env          = vpc.env
          vpc_name          = vpc.name
          sg_name = k
          ingress_path = v.ingress
          egress_path  = v.egress
          info  = v.info
        }
      ]
  ])

}
