variable "module_region" {
  type        = string
  description = "AWS Region"
  default     = null
}

variable "module_profile" {
  type        = string
  description = "AWS Profile"
  default     = null
}

provider "aws" {
  region  = var.module_region
  profile = var.module_profile
}

variable "yaml_file" {
  type        = string
  description = "file location for yaml config data"
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
        gw                = can(v.associate_with)  ? v.associate_with : null
      }
    ]
  ])

  ## To be used in internet_gateway.tf
#  igw = flatten([
#    for vpc in local.vpcs : [ 
#      for k, v in vpc.internet_gateway : {
#        vpc_id            = vpc.name
#        env               = vpc.env
#        igw_name          = k
#        tags              = vpc.tags
#        subnet_name       = v.subnets
#   }]
#  ])
  igw = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.internet_gateway : {
        vpc_id            = vpc.name
        env               = vpc.env
        igw_name          = k
        sub_name          = v
      }
    ]
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
        pub_sub           = v.pub_sub
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


  rtb = flatten([
    for vpc in local.vpcs : [
      for k,v in vpc.route_table_assoc : {
          env          = vpc.env
          vpc_name     = vpc.name
          subnet_name  = can(k) ? k : null
          gw           = can(v.gw) ? v.gw : null
          route_sub    = can(v.public) ? k : v.nat_subnet
          public       = can(v.public) ? v.public : false
        }
    ]
  ])


  sgroups = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.security_groups : {
          env          = vpc.env
          vpc_name     = vpc.name
          sg_name      = k
          ingress_path = v.ingress
          egress_path  = v.egress
          info         = v.info
        }
      ]
  ])

  sgroup_rule = flatten([
    for vpc in local.vpcs : [
       for k, v in vpc.security_group_rule : {
          env          = vpc.env
          vpc_name     = vpc.name
          type         = v.type
          from_port    = v.from_port
          to_port      = v.to_port
          description  = k
          source_group = v.source_group
          dest_group   = v.dest_group
          protocol     = v.protocol
        }
      ]
  ])

  lbs = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.load_balancer : {
          env             = vpc.env
          vpc_name        = vpc.name
          type            = v.type != null ? v.type : "application"
          internal        = v.internal != null ? v.internal : false
          lb_name         = k
          security_groups = v.security_groups != null ? v.security_groups : []
          subnets         = v.subnets != null ? v.subnets : []
        } 
      ]
  ])

  lb_target_group = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.lb_target_group : {
          env             = vpc.env
          vpc_name        = vpc.name
          tg_name         = can(k) ? k : null
          port            = can(v.port) ? v.port : null
          protocol        = can(v.protocol) ? v.protocol : null
          target_type     = can(v.target_type) ? v.target_type : null
          hc_enabled      = can(v.hc_enabled) ? v.hc_enabled : null
          hc_path         = can(v.hc_path) ? v.hc_path : null
          hc_timeout      = can(v.hc_timeout) ? v.hc_timeout : null
        }
      ]
  ])


  lb_listener = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.lb_listener : {
          env             = vpc.env
          vpc_name        = vpc.name
          listener_name   = can(k) ? k : null
          lb              = can(v.lb) ? v.lb : null
          port            = can(v.port) ? v.port : null
          protocol        = can(v.protocol) ? v.protocol : null
          tgroup          = can(v.tgroup) ? v.tgroup : null
          tgroup_type     = can(v.tgroup_type) ? v.tgroup_type : null
        }
      ]
  ])

  asgs = flatten([
    for vpc in local.vpcs : [
      for k, v in vpc.autoscaling_group : {
          env                 = vpc.env
          vpc_name            = vpc.name
          launch_config       = can(v.launch_config) ? v.launch_config : []
          name                = can(k) ? k : null
          vpc_zone_identifier = can(v.vpc_zone_identifier) ? v.vpc_zone_identifier : []
          max_size            = can(v.max_size) ? v.max_size : null
          min_size            = can(v.min_size) ? v.min_size : null
          health_check_grace_period = can(v.health_check_grace_period) ? v.health_check_grace_period : null
          health_check_type         = can(v.health_check_type) ? v.health_check_type : null
          desired_capacity          = can(v.desired_capacity) ? v.desired_capacity : null
          force_delete		    = can(v.force_delete) ? v.force_delete : null
          launch_configuration      = can(v.launch_configuration) ? v.launch_configuration : null
          target_group_arns         = can(v.target_group_arns) ? v.target_group_arns : null
        }
      ]
  ])

}
