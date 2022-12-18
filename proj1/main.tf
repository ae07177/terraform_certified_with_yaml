provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

variable "yaml_config" {
  type        = string
  description = "file location for yaml config data"
  default     = "/Users/arvind/terraform_certified_with_yaml/proj1/vars.yaml"
  #default     = null
}

#variable "security_group_name" {}


module "vpc" {
  source    = "./modules/aws"
  yaml_file = var.yaml_config
  #  security_group_name = var.security_group_name
}
