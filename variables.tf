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
  type        = string
  description = "클러스터 이름"
}

variable "app_ec2_type" {
  type        = string
  description = "admin 노드들에 쓸 인스턴스 타입"
  default     = "t3.small"
}

variable "app_auto_scaling_group" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "App NodeGroup에서 노드의 최대, 최소, 희망 크기"
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "admin_ec2_type" {
  type        = string
  description = "admin 노드들에 쓸 인스턴스 타입"
  default     = "t3.medium"
}

variable "admin_auto_scaling_group" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "Admin NodeGroup에서 노드의 최대, 최소, 희망 크기"
  default = {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
}

variable "make_kube_config" {
  type        = bool
  description = "~/.kube/config에 클러스터 접근 권한을 덮어쓸 것인가?"
}
