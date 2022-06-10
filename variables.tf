variable "aws_region" {
  type        = string
  description = "리전"
}

variable "number_of_subnet" {
  type        = number
  description = "서브넷 개수"
  default     = 2
}
variable "cluster_name" {
  type = string
}

variable "nodegroup_instance_type" {
  type    = string
  default = "t3.small"
}


variable "app_auto_scaling_group" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "App NodeGroup에서 노드의 최대, 최소, 희망 크기를 정한다."
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "admin_auto_scaling_group" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "App NodeGroup에서 노드의 최대, 최소, 희망 크기를 정한다."
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}
