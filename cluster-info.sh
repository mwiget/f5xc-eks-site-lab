#!/bin/bash
AWS_REGION="us-west-1"
EKS_NAME="marcel-eks"
aws eks list-clusters --region $AWS_REGION
aws eks describe-cluster --name ${EKS_NAME} --query cluster.status --region $AWS_REGION

#aws eks update-kubeconfig --name ${EKS_NAME} --region $AWS_REGION
export KUBECONFIG=${EKS_NAME}.kubeconfig
kubectl get nodes -o wide

oidc_id=$(aws eks describe-cluster --name $EKS_NAME --query "cluster.identity.oidc.issuer" --region $AWS_REGION --output text | cut -d '/' -f 5)
echo ""
echo -n "IAM OIDC provider: "
aws eks describe-cluster --name $EKS_NAME --query "cluster.identity.oidc.issuer" --region $AWS_REGION --output text
echo ""
kubectl get pods -n ves-system
