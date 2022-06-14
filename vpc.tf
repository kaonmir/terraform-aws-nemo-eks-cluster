locals {
  az_names       = data.aws_availability_zones.available.names
  subnet_numbers = [for x in range(var.number_of_subnet) : x % length(local.az_names)]
}

data "aws_availability_zones" "available" {
  exclude_names = []
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # TODO: CIDR도 var로 유동적으로 관리 vpc: /16, subnet: /24
  name = var.cluster_name
  cidr = "10.1.0.0/16"
  azs  = [for x in local.subnet_numbers : local.az_names[x]]

  private_subnets = [for num in local.subnet_numbers : "10.1.${num}.0/24"]
  public_subnets  = [for num in local.subnet_numbers : "10.1.10${num}.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  create_vpc         = true

  private_subnet_tags = {
    "Name"                                      = "${var.cluster_name}-public_subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  public_subnet_tags = {
    "Name"                                      = "${var.cluster_name}-private_subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  tags = {
    "Name"                                      = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Terraform                                   = "true"
    Environment                                 = "dev"
  }
}
