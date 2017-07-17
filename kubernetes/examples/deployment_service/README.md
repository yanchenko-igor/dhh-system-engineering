# Deployment and Service example

A simple example of a Kubernetes deployment, different service types and a horizontal pod autoscaler.

Files:

- `app.yaml`: Deployment
- `hpa.yaml`: Horizontal pod autoscaler
- `service-nodeport.yaml`: This example makes the deployment accessible on port 32001 on each cluster node. An internal or external load balancer should be used in front of the cluster nodes.
- `service-clusterip.yaml`: This example makes the deployment accessible on port 80 within the kubernetes cluster. The service can be accessed by an IP address or by a DNS record by other deployments running on the cluster. The type of service does not make the deployment accessible externally.
- `service-loadbalancer.yaml`: This example makes the deployment accessible via a public load balancer. The load balancer is created and managed by Kubernetes automatically.

## Try it

First deploy the application:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/app.yaml
```

Then choose the type of service you want to use and apply it:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/service-loadbalancer.yaml
```

Optionally create the horizontal pod autoscaler:

```
kubectl create -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/deployment_service/hpa.yaml
```

## Verify
