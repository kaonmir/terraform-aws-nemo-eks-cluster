resource "aws_iam_role" "eks_node" {
  name = "eks_node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

# t3 small node group for app logics
resource "aws_eks_node_group" "nodegroup_app" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "nodegroup_app"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.eks_private_subnet[*].id
  instance_types  = [var.app_ec2_type]
  disk_size       = 15

  labels = {
    "role" = "nodegroup_app"
  }

  scaling_config {
    desired_size = var.app_auto_scaling_group.desired_size
    min_size     = var.app_auto_scaling_group.min_size
    max_size     = var.app_auto_scaling_group.max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name" = "${aws_eks_cluster.eks_cluster.name}_eks_node"
    "role" = "app"
  }
}

# t3 small node group for admin
resource "aws_eks_node_group" "nodegroup_admin" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "nodegroup_admin"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.eks_private_subnet[*].id
  instance_types  = [var.admin_ec2_type]
  disk_size       = 10

  labels = {
    "role" = "nodegroup_admin"
  }

  scaling_config {
    desired_size = var.admin_auto_scaling_group.desired_size
    min_size     = var.admin_auto_scaling_group.min_size
    max_size     = var.admin_auto_scaling_group.max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name" = "${aws_eks_cluster.eks_cluster.name}_eks_node"
    "Role" = "admin"
  }

  taint {
    key    = "TAINED_BY_ADMIN"
    effect = "NO_SCHEDULE"
  }
}
