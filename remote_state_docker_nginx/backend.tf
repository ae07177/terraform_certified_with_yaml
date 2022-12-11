terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }

  required_version = ">= 0.13"
  backend "s3" {
    profile = "default"
    region  = "us-east-1"
    key     = "terraform.tfstate"
    bucket  = "terraformstatebucketarvind"
  }
}
