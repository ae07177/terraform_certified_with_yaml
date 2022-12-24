variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "profile" {
  type        = string
  description = "AWS Profile"
  default     = "acguru"
}

variable "yaml_config" {
  type        = string
  description = "file location for yaml config data"
  default     = "/Users/arvind/terraform_certified_with_yaml/proj1/vars.yaml"
  #default     = null
}

#variable "security_group_name" {}


module "vpc" {
  source         = "./modules/aws"
  yaml_file      = var.yaml_config
  module_region  = var.region
  module_profile = var.profile
  #  security_group_name = var.security_group_name
}
