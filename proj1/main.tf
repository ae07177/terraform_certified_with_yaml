provider "aws" {
  region  = "us-east-1"
  profile = "acguru"
}


module "vpc" {
  source = "./modules/aws"
}
