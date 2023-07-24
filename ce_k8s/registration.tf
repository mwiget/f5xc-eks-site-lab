resource "volterra_registration_approval" "node" {
  depends_on = [ null_resource.ce-k8s ]
  count = var.worker_node_count
  cluster_name  = var.cluster_name
  cluster_size  = var.worker_node_count > 1 ? 3 : 1
  retry = 10
  wait_time = 60
  hostname = format("vp-manager-%d", count.index)
}

resource "null_resource" "check_site_status" {
  depends_on = [volterra_registration_approval.node]
  provisioner "local-exec" {
    command     = format("./scripts/check.sh %s %s %s", local.site_get_url, local.f5xc_api_token, local.f5xc_tenant)
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}

resource "volterra_site_state" "decommission_when_delete" {
  depends_on = [volterra_registration_approval.node]
  name       = var.cluster_name
  when       = "delete"
  state      = "DECOMMISSIONING"
  retry      = 5
  wait_time  = 60
}
