locals {
  base_offset               = length(substr(var.f5xc_api_url, 8, -1)) - 4
  is_production_env         = endswith(var.f5xc_api_url, ".io/api")
  maurice_endpoint_url      = local.is_production_env ? format("https://%s", replace(substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 23, -1), "console", "register")) : format("https://register.%s", substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 19, -1))
  maurice_mtls_endpoint_url = local.is_production_env ? format("https://%s", replace(substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 23, -1), "console", "register-tls")) : format("https://register-tls.%s", substr(substr(substr(var.f5xc_api_url, 8, -1), 0, local.base_offset), 0 - 19, -1))

  f5xc_tenant    = var.f5xc_tenant
  f5xc_api_token = var.f5xc_api_token
  site_get_uri   = format("config/namespaces/system/sites/%s", var.cluster_name)
  site_get_url   = format("%s/%s?response_format=GET_RSP_FORMAT_DEFAULT", var.f5xc_api_url, local.site_get_uri)

  ce_k8s_yaml = templatefile("./templates/ce_k8s.yaml.tmpl", {
    cluster_name              = var.cluster_name
    latitude                  = var.latitude,
    longitude                 = var.longitude,
    token                     = volterra_token.site.id,
    replicas                  = var.worker_node_count,
    maurice_endpoint_url      = local. maurice_endpoint_url,
    maurice_mtls_endpoint_url = local.maurice_mtls_endpoint_url
  })
}
