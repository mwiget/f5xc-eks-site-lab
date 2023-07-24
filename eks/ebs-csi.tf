data "tls_certificate" "eks" {
 depends_on = [ aws_eks_node_group.eks ]
 url = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
 depends_on = [ aws_eks_node_group.eks ]
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
     identifiers = [aws_iam_openid_connect_provider.eks.arn]
     type = "Federated"
    }
    condition {
      test      = "StringEquals"
      variable  = format("oidc.eks.%s.amazonaws.com/id/%s:aud", var.aws_region, reverse(split("/", aws_eks_cluster.eks.identity.0.oidc.0.issuer))[0])
      values    = [ "sts.amazonaws.com"]
    }
    condition {
      test      = "StringEquals"
      variable  = format("oidc.eks.%s.amazonaws.com/id/%s:sub", var.aws_region, reverse(split("/", aws_eks_cluster.eks.identity.0.oidc.0.issuer))[0])
      values    = [ "system:serviceaccount:kube-system:ebs-csi-controller-sa" ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  depends_on      = [ aws_eks_node_group.eks ]
  client_id_list  = ["sts.amazonaws.com", "system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity.0.oidc.0.issuer
  tags = {
    cluster = var.cluster_name
    owner   = var.owner
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  depends_on          = [ aws_eks_node_group.eks ]
  assume_role_policy  = data.aws_iam_policy_document.cluster_assume_role_policy.json
  name                = format("%s-ebs-csi-driver", var.cluster_name)
  tags = {
    cluster = var.cluster_name
    owner   = var.owner
  }
}

resource "aws_iam_policy_attachment" "ebs_csi_driver" {
  depends_on  = [ aws_eks_node_group.eks ]
  name        = "Policy Attachement"
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles       = [aws_iam_role.ebs_csi_driver.name]
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  depends_on                = [ aws_eks_node_group.eks ]
  cluster_name              = aws_eks_cluster.eks.name
  addon_name                = "aws-ebs-csi-driver"
  service_account_role_arn  = format("%s-ebs-csi-driver", aws_eks_cluster.eks.role_arn)
  tags = {
    cluster = var.cluster_name
    owner   = var.owner
  }
}

