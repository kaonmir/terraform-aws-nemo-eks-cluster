variable "aws_region" {
  type = string
}

variable "number_of_subnet" {
  type    = number
  default = 2
}

variable "cluster_name" {
  type = string
}

variable "nodegroup_instance_type" {
  type    = string
  default = "t3.small"
}

variable "nodegroup_instance_desired_size" {
  type    = number
  default = 1
}
