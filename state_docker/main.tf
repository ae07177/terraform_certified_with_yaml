terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}

provider "docker" {
  # Configuration options
}

# Pull Latest CentOS7 Image
resource "docker_image" "tf-centos" {
  name = "centos:7"
  keep_locally = true
}

# Create a Container Using the Image
resource "docker_container" "centos7-tf" {
  image = docker_image.tf-centos.latest
  name  = "tf-centos7"
  start = true
  command = [ "sleep", "500" ]
}

