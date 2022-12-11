locals {
  config = yamldecode(file("example.yaml"))

  data = local.config.data
  description = local.config.description

  data_keys = keys(local.data)
  data_values = values(local.data)

  description_keys = keys(local.description)
  description_values = values(local.description)

  avengers = ["ironman", "captain america", "thor","doctor strange","spider man","hulk","black panther","black widow"]

}

resource "null_resource" "avengers" {
  for_each = toset(local.avengers)
  triggers = {
    name = each.value
  }
}


output "data_keys" {
  value = local.data_keys
}

output "data_values" {
  value = local.data_values
}

output "description_keys" {
  value = local.description_keys
}

output "description_values" {
  value = local.description_values
}

output "avengers" {
  value = null_resource.avengers
}
