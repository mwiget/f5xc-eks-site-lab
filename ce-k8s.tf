locals {
   ce_k8s_yaml = templatefile("./templates/ce_k8s.yaml", {
    cluster_name              = aws_eks_cluster.eks.name,
    latitude                  = var.latitude,
    longitude                 = var.longitude,
    token                     = volterra_token.site.id,
    replicas                  = var.worker_node_count,
    maurice_endpoint_url      = local. maurice_endpoint_url,
    maurice_mtls_endpoint_url = local.maurice_mtls_endpoint_url
    storage_class             = "gp2"
  })
}

resource "volterra_token" "site" {
  name      = var.cluster_name
  namespace = "system"
}

resource "local_file" "ce_k8s_yaml" {
  content  = local.ce_k8s_yaml
  filename = "./ce_k8s.yaml"
}

resource "null_resource" "ce-k8s" {
  depends_on = [ aws_eks_addon.aws-ebs-csi-driver ]
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.cluster_name}.kubeconfig apply -f ce_k8s.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    # hack referencing kubeconfig, because destroy doesn't allow var references
    command = "kubectl --kubeconfig=*.kubeconfig destroy -f ce_k8s.yaml"
  }
}

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
