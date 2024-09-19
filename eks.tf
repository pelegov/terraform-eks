### Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = var.role_name_cluster

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "eks.amazonaws.com"
      }
    }]
  })
}

# Policy for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}

# Call VPC module

### EKS Cluster Creation
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = "1.25"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = var.security_group_id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
    aws_iam_role_policy_attachment.eks_vpc_policy
  ]
}

## IAM role for Node group
resource "aws_iam_role" "eks_node_role" {
  name = var.role_name_node_group

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ec2.amazonaws.com"
      }
    }]
  })
}

# Policy for Node group
resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

### EKS Node Group Creation
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = [var.instance_type]

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_policy
  ]
}
