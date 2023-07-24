locals {
  kubeconfig = templatefile("./templates/kubeconfig.tftpl", {
    cluster_name = aws_eks_cluster.eks.name,
    clusterca    = aws_eks_cluster.eks.certificate_authority[0].data,
    endpoint     = aws_eks_cluster.eks.endpoint,
  })
}
