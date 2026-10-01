variable "vpc_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "mado-cloud"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
