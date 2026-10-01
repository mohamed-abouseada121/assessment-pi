variable "project_name" {
  type    = string
  default = "mado-cloud"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "tags" {
  type    = map(string)
  default = {}
}
