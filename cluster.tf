resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.eks.*.id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
  tags = {
    cluster = var.cluster_name
    owner   = var.owner
  }
}

resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.cluster_name
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.eks.*.id

  scaling_config {
    desired_size = var.worker_node_count
    max_size     = var.worker_node_count
    min_size     = var.worker_node_count
  }

  instance_types  = ["t2.xlarge"]

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    cluster = var.cluster_name
    owner   = var.owner
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "local_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = format("./%s.kubeconfig", var.cluster_name)
}
