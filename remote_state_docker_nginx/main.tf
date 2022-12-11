provider "docker" {}

resource "docker_image" "nginx-image" {
  name = "nginx"
}

resource "docker_container" "terraform-nginx" {
  image = docker_image.nginx-image.latest
  name  = "terraform-nginx"
  ports {
    internal = 80
    external = var.external_port
    protocol = "tcp"
  }
}

output "url" {
  description = "Browser URL for container Site"
  value	      = join(":", ["http://localhost", tostring(var.external_port)])
}
