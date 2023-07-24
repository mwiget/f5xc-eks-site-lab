resource "volterra_token" "site" {
  name      = var.cluster_name
  namespace = "system"
}

resource "local_file" "ce_k8s_yaml" {
  content  = local.ce_k8s_yaml
  filename = "./ce_k8s.yaml"
}

resource "null_resource" "ce-k8s" {
  provisioner "local-exec" {
    command     = "kubectl --kubeconfig=../eks/kubeconfig apply -f ./ce_k8s.yaml"
  }
  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue
    command     = "kubectl --kubeconfig=../eks/kubeconfig delete -f ./ce_k8s.yaml"
  }
}

