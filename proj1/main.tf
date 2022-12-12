provider "aws" {
  region  = "us-east-1"
  profile = "acguru"
}

variable "yaml_config" {
  type        = string
  description = "file location for yaml config data"
  default     = "/Users/arvind/terraform_certified_with_yaml/proj1/vars.yaml"
  #default     = null
}


module "vpc" {
  source = "./modules/aws"
  yaml_file = var.yaml_config
}
