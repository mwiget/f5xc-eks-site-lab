Simple pod to test dynamic volume provisioning via storageclass gp2.

```
$ kubectl apply -f claim.yaml -f pod.yaml 
persistentvolumeclaim/ebs-claim created
pod/app created
```

```
 kubectl get pod
NAME   READY   STATUS    RESTARTS   AGE
app    1/1     Running   0          31s
```

Running status indicates successful creating of a persistentvolumeclaim:

```
kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
ebs-claim   Bound    pvc-d0566097-178a-4220-859e-2aec25df629e   4Gi        RWO            gp2            2m47s
```

Delete pod and claim:

```
kubernetes  delete -f pod.yaml -f claim.yaml 
pod "app" deleted
persistentvolumeclaim "ebs-claim" deleted
```
