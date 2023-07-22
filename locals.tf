locals {
  kubeconfig = templatefile("./templates/kubeconfig.tftpl", {
    cluster_name = aws_eks_cluster.eks.name,
    clusterca    = aws_eks_cluster.eks.certificate_authority[0].data,
    endpoint     = aws_eks_cluster.eks.endpoint,
  })

  base_offset               = length(substr(var.f5xc_api_url, 8, -1)) - 4
  is_production_env         = endswith(var.f5xc_api_url, ".io/api")
  maurice_endpoint_url      = local.is_production_env ? format("https://%s", replace(substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 23, -1), "console", "register")) : format("https://register.%s", substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 19, -1))
  maurice_mtls_endpoint_url = local.is_production_env ? format("https://%s", replace(substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 23, -1), "console", "register-tls")) : format("https://register-tls.%s", substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 19, -1))

  ce_k8s_yaml = templatefile("./templates/ce_k8s.yaml", {
    cluster_name              = aws_eks_cluster.eks.name,
    latitude                  = var.latitude,
    longitude                 = var.longitude,
    token                     = volterra_token.site.id,
    replicas                  = var.worker_node_count,
    maurice_endpoint_url      = local. maurice_endpoint_url,
    maurice_mtls_endpoint_url = local.maurice_mtls_endpoint_url,
    storage_class             = "gp2"
  })
}
