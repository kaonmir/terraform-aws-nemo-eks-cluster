resource "aws_iam_role" "nemo_eks_node" {
  name = "nemo_eks_node"

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

resource "aws_iam_role_policy_attachment" "nemo_eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nemo_eks_node.name
}

resource "aws_iam_role_policy_attachment" "nemo_eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nemo_eks_node.name
}

resource "aws_iam_role_policy_attachment" "nemo_eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nemo_eks_node.name
}

# t3 small node group for business logics
resource "aws_eks_node_group" "nodegroup_business" {
  cluster_name    = aws_eks_cluster.nemo_eks_cluster.name
  node_group_name = "nodegroup_business"
  node_role_arn   = aws_iam_role.nemo_eks_node.arn
  subnet_ids      = aws_subnet.nemo_eks_private_subnet[*].id
  instance_types  = [var.nodegroup_instance_type]
  disk_size       = 15

  labels = {
    "role" = "nodegroup_business"
  }

  scaling_config {
    desired_size = var.nodegroup_instance_desired_size
    min_size     = max(var.nodegroup_instance_desired_size - 1, 0)
    max_size     = var.nodegroup_instance_desired_size + 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name" = "${aws_eks_cluster.nemo_eks_cluster.name}_nemo_eks_node"
    "role" = "business"
  }
}

# t3 small node group for admin
resource "aws_eks_node_group" "nodegroup_admin" {
  cluster_name    = aws_eks_cluster.nemo_eks_cluster.name
  node_group_name = "nodegroup_admin"
  node_role_arn   = aws_iam_role.nemo_eks_node.arn
  subnet_ids      = aws_subnet.nemo_eks_private_subnet[*].id
  instance_types  = [var.nodegroup_instance_type]
  disk_size       = 10

  labels = {
    "role" = "nodegroup_admin"
  }

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  depends_on = [
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nemo_eks_node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name" = "${aws_eks_cluster.nemo_eks_cluster.name}_nemo_eks_node"
    "Role" = "admin"
  }

  taint {
    key    = "TAINED_BY_ADMIN"
    effect = "NO_SCHEDULE"
  }
}
