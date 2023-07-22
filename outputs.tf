output "cluster_id" {
  description = "EKS cluster ID."
  value       = aws_eks_cluster.eks.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.eks.endpoint
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "oidc" {
  value = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}
