# Deploy F5XC Kubernetes Site on AWS EKS

## Steps

1. Set credentials

Create terraform.tfvars with required credentials based on terraform.tfvars.example
in folder eks and ce_k8s.

2. Deploy EKS

```
cd eks
terraform apply
```

A 3-node AWS EKS kubernetes cluster is deployed with the required EBS CSI driver according to 
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html (since kubernetes 1.23, this is no
longer automatically created).

3. Deploy kubernetes site

```
cd ce_k8s
terraform apply
```

This deploys F5 XC Kubernetes Site (https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site)
on the EKS cluster with the following adjustments:

- Use storageClass gp2 instead of standard to match the default on EKS:

```
$ kubectl get storageclass
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  8h
```

This creates a F5XC site registration token, deploys the CE pods, auto-registers them in F5XC and 
waits for the site to become online.

4. Validate

```
source env.sh
kubectl get nodes -n ves-system
```


