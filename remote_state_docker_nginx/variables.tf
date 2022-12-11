variable "external_port" {
  type	     =  number
  default    =  8080
  validation {
    condition = can(regex("8080|80", var.external_port))
    error_message = "Port Value can either be 8080 or 80"
  }
} 
