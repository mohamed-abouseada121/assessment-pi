variable "project_name" {
  type    = string
  default = "mado-cloud"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "subnet_id" {
  type = string
}

variable "ec2_security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
