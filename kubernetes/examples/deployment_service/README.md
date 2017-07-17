# Deployment and Service example

A simple example of a Kubernetes deployment, different service types and a horizontal pod autoscaler.

Files:

- `app.yaml`: Deployment
- `hpa.yaml`: Horizontal pod autoscaler
- `service-nodeport.yaml`: This example makes the deployment accessible on port 32001 on each cluster node. An internal or external load balancer should be used in front of the cluster nodes.
- `service-clusterip.yaml`: This example makes the deployment accessible on port 80 within the kubernetes cluster. The service can be accessed by an IP address or by a DNS record by other deployments running on the cluster. The type of service does not make the deployment accessible externally.
- `service-loadbalancer.yaml`: This example makes the deployment accessible via a public load balancer. The load balancer is created and managed by Kubernetes automatically.

## Try it

Create a deployment for the application:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/app.yaml
deployment "example-app" created
```

Choose the type of service you want to use and create it:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/service-loadbalancer.yaml
service "example-app" created
```

Optionally create the horizontal pod autoscaler:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/hpa.yaml
horizontalpodautoscaler "example-app" created
```

## Verify

Check pods from the deployment are running:

```
kubectl get pods -l name=example-app
NAME                          READY     STATUS    RESTARTS   AGE
example-app-654009903-9zd5b   1/1       Running   0          54s
example-app-654009903-kq253   1/1       Running   0          54s
example-app-654009903-xq1jl   1/1       Running   0          54s
example-app-654009903-z7sv1   1/1       Running   0          54s
```

Check the service is created:

```
kubectl get -o wide services -l name=example-app
NAME          CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE       SELECTOR
example-app   100.65.122.47   aaaaaaaaad811e789830a2590f5bad-222222222.eu-west-1.elb.amazonaws.com   80:32485/TCP   3m       name=example-app
```

Check access to the deployment via the service:

```
curl http://aaaaaaaaad811e789830a2590f5bad-222222222.eu-west-1.elb.amazonaws.com
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

Check the horizontal pod autoscaler:

```
kubectl get hpa example-app
NAME          REFERENCE                TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
example-app   Deployment/example-app   0% / 40%   4         50        4          47s
```
