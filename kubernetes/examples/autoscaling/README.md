# Kubernetes node and deployment autoscaling

Pod and cluster node autoscaling are configured separately and operate in different ways.

## Pod autoscaling

An addon is required to collect statistics about pods that is used by the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). Since we use [kops](https://github.com/kubernetes/kops) to install and configure clusters, we will use the kops addon:

https://github.com/kubernetes/kops/tree/master/addons/monitoring-standalone

Choose the relevant version and install it:

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.6.0.yaml
```

Then you should have a new pod running in the `kube-system` namespace:

```
$ kubectl get pods -n kube-system -l k8s-app=heapster
NAME                        READY     STATUS    RESTARTS   AGE
heapster-1743311875-9pbvx   2/2       Running   0          4d
```

Now you just need to add a Horizontal Pod Autoscaler for a deployment. This is detailed [here](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/deployment_service)

## Node autoscaling

Again, since we use [kops](https://github.com/kubernetes/kops) to install and configure clusters, we will use the kops addon:

https://github.com/kubernetes/kops/tree/master/addons/cluster-autoscaler

Follow those steps and then you should have a new pod running in the `kube-system` namespace:

```
$ kubectl get pods -n kube-system -l k8s-app=cluster-autoscaler
NAME                                  READY     STATUS    RESTARTS   AGE
cluster-autoscaler-2298777855-87lw2   1/1       Running   0          12d
```

Cluster node autoscaling does not scale based on CPU or other system metrics, it scales based on the resource requirements of pods. The setting of these requirements is detailed here:

https://kubernetes.io/docs/concepts/policy/resource-quotas/

When a pod is scheduled to run, if there are not enough free resources to meet the pods requirements, Kubernetes will create another cluster node.

## Testing

At this point cluster node and pod autoscaling should now be possible. To test it we will run a CPU stress test container and observe the results.

Create a deployment:

```
$ cat <<EOF | kubectl create -f -

apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: stress-test
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: stress-test
    spec:
      containers:
      - name: stress-test
        image: petarmaric/docker.cpu-stress-test:latest
        resources:
          requests:
            cpu: 1

EOF

deployment "stress-test" created
```

Create the Horizontal Pod Autoscaler:

```
$ kubectl autoscale deployment stress-test --min=1 --max=20 --cpu-percent=30
deployment "stress-test" autoscaled
```

Now wait a minute or two for the initial CPU measurements to be taken and then you can see the status of the HPA:

```
$ kubectl get hpa stress-test
NAME          REFERENCE                TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
stress-test   Deployment/stress-test   100% / 30%   1         20        1          1m
```

It should start creating more pods pretty quickly:

```
$ kubectl get pods -l app=stress-test
NAME                          READY     STATUS    RESTARTS   AGE
stress-test-761738208-9nwsv   1/1       Running   1          8m
stress-test-761738208-fp9f7   1/1       Running   0          37s
stress-test-761738208-g78vb   0/1       Pending   0          37s
stress-test-761738208-nj2bg   0/1       Pending   0          37s
```

Describe a pod that has a status of `Pending` to see the events:

```
$ kubectl describe pod stress-test-761738208-nj2bg
...

Events:
  FirstSeen	LastSeen	Count	From			SubObjectPath	Type		Reason			Message
  ---------	--------	-----	----			-------------	--------	------			-------
  1m		1m		1	cluster-autoscaler		Normal		TriggeredScaleUp	pod triggered scale-up, group: cluster1_node, sizes (current/new): 3/5
  1m		14s		8	default-scheduler			Warning		FailedScheduling	No nodes are available that match all of the following predicates:: Insufficient cpu (6), PodToleratesNodeTaints (3).
```

Then you should be able to see new nodes being created in order to run the newly create pods:

```
$ kubectl get nodes
NAME                                            STATUS     AGE       VERSION
ip-172-22-1-231.eu-central-1.compute.internal   Ready      12d       v1.6.2
ip-172-22-4-51.eu-central-1.compute.internal    Ready      4d        v1.6.2
ip-172-22-2-248.eu-central-1.compute.internal   NotReady   8s        v1.6.2
ip-172-22-4-13.eu-central-1.compute.internal    NotReady   12s       v1.6.2
```

Clean up after the test:

```
$ kubectl delete hpa stress-test
horizontalpodautoscaler "stress-test" deleted
$ kubectl delete deployment stress-test
deployment "stress-test" deleted
```
