data "tls_certificate" "cluster" {
 url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com", "system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  tags = {
    cluster = local.cluster_name
    owner   = var.owner
  }
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
     identifiers = [aws_iam_openid_connect_provider.cluster.arn]
     type = "Federated"
    }
    condition {
      test      = "StringEquals"
      variable  = format("oidc.eks.%s.amazonaws.com/id/%s:aud", var.aws_region, reverse(split("/", data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer))[0])
      values    = [ "sts.amazonaws.com"]
    }
    condition {
      test      = "StringEquals"
      variable  = format("oidc.eks.%s.amazonaws.com/id/%s:sub", var.aws_region, reverse(split("/", data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer))[0])
      values    = [ "system:serviceaccount:kube-system:ebs-csi-controller-sa" ]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
  name = format("%s-ebs-csi-driver", local.cluster_name)
  tags = {
    cluster = local.cluster_name
    owner   = var.owner
  }
}

resource "aws_iam_policy_attachment" "ebs_csi_driver" {
  name = "Policy Attachement"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles       = [aws_iam_role.ebs_csi_driver.name]
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name              = data.aws_eks_cluster.cluster.name
  addon_name                = "aws-ebs-csi-driver"
  service_account_role_arn  = format("arn:aws:iam::%s:role/%s-ebs-csi-driver", split(":", module.eks.cluster_arn)[4], local.cluster_name)
  tags = {
    cluster = local.cluster_name
    owner   = var.owner
  }
}

