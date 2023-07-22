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
}

resource "volterra_registration_approval" "node" {
  depends_on = [ null_resource.ce-k8s ]
  count = var.worker_node_count
  cluster_name  = var.cluster_name
  cluster_size  = var.worker_node_count > 1 ? 3 : 1
  retry = 5
  wait_time = 60
  hostname = format("vp-manager-%d", count.index)
}
