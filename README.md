# Deploy F5XC Kubernetes Site on AWS EKS

## Steps

1. Set credentials

Create terraform.tfvars with required credentials based on terraform.tfvars.example
in folder eks and ce_k8s.

2. Deploy EKS

```
cd eks
terraform apply
cd ..
```

A 3-node AWS EKS kubernetes cluster is deployed with the required EBS CSI driver according to 
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html (since kubernetes 1.23, this is no
longer automatically created).

3. Deploy kubernetes site

```
cd ce_k8s
terraform apply
cd ..
```

This deploys F5 XC Kubernetes Site (https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site)
on the EKS cluster using default storage class (gp2):

- Set storageClass gp2 as default on EKS:

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
kubectl get pods -n ves-system

NAME                         READY   STATUS    RESTARTS      AGE
etcd-0                       2/2     Running   0             14m
etcd-1                       2/2     Running   0             14m
etcd-2                       2/2     Running   0             14m
prometheus-7bcc474c9-xj8f6   5/5     Running   0             14m
ver-0                        17/17   Running   3 (21s ago)   14m
ver-1                        17/17   Running   2 (13m ago)   13m
ver-2                        17/17   Running   2 (12m ago)   12m
volterra-ce-init-d98xj       1/1     Running   0             18m
volterra-ce-init-fjczn       1/1     Running   0             18m
volterra-ce-init-qbhjb       1/1     Running   0             18m
vp-manager-0                 1/1     Running   2 (16m ago)   17m
vp-manager-1                 1/1     Running   2 (15m ago)   17m
vp-manager-2                 1/1     Running   3 (15m ago)   17m
```


