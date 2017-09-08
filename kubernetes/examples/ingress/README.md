# Kubernetes Ingress

The [Ingress resource](https://kubernetes.io/docs/concepts/services-networking/ingress/) provides external access to services within a Kubernetes cluster. While a standard `LoadBalancer` service can also provide this, the Ingress resource has some advantages:

- It can provide access to multiple internal services
- It can load balance and split traffic between multiple internal services
- HTTP path/URI based routing
- Supports TLS

In many cases an `Ingress` resource will be the sole external entry point into a cluster, providing access to many applications within a Kubernetes cluster.

## Try it

In this example traffic will be split between 4 applications as follows:

1. Traffic for host `app1.domain.com` with path `/frontend` will go to the `app1-frontend` application
2. Traffic for host `app1.domain.com` with path `/backend` will go to the `app1-backend` application
3. Traffic for host `app2.domain.com` will go to the `app2` application
4. Traffic for host `app3.domain.com` will go to the `app3` application

Create the 4 applications:

```
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app1-backend.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app1-frontend.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app2.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app3.yaml
```

There should be 4 pods running now:

```
$ kubectl get pods
NAME                                                      READY     STATUS    RESTARTS   AGE
app1-145361462-j52l1                                      1/1       Running   0          16h
app2-361171512-x9j95                                      1/1       Running   0          16h
app3-backend-4229304356-wxrj0                             1/1       Running   0          15h
app3-frontend-609358164-tk6kt                             1/1       Running   0          15h
```

There are different Ingress controllers available, here we will the [nginx-ingress](https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress) one and install it with [Helm](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/helm):

```
helm install --name ingress1 stable/nginx-ingress
```

Now there should be 2 new pods created:

```
kubectl get pods -l app=nginx-ingress
NAME                                                     READY     STATUS    RESTARTS   AGE
ingress1-nginx-ingress-controller-3121480484-6b5w8       1/1       Running   0          2m
ingress1-nginx-ingress-default-backend-541177211-h8427   1/1       Running   0          2m
```

An AWS ELB will also be automatically created.

Now create the `Ingress` resource:

```
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/ingress.yaml
```

Wait 2 minutes and then check the ingress controller was created successfully by looking at the events of the ingress, there should be `CREATE` and `UPDATE` events:

```
kubectl describe ingress test-ingress
Name:			test-ingress
Namespace:		default
Default backend:	default-http-backend:80 (<none>)
Rules:
  Host			Path	Backends
  ----			----	--------
  app1.domain.com
    			/frontend 	app1-frontend:80 (<none>)
    			/backend 	app1-backend:80 (<none>)
  app2.domain.com
    			 	app2:80 (<none>)
  app3.domain.com
    			 	app3:80 (<none>)
Annotations:
Events:
  FirstSeen	LastSeen	Count	From			SubObjectPath	Type		Reason	Message
  ---------	--------	-----	----			-------------	--------	------	-------
  28s		28s		1	ingress-controller			Normal		CREATE	Ingress default/test-ingress
  5s		5s		1	ingress-controller			Normal		UPDATE	Ingress default/test-ingress
```

Get the ELB DNS record from the ingress controller:

```
ELB_ADDRESS=$(kubectl get -o wide service ingress1-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Use the ELB DNS record to test `app1-frontend`:

```
curl http://$ELB_ADDRESS/frontend -H "Host: app1.domain.com"
app1-frontend
```

Test `app1-backend`:

```
curl http://$ELB_ADDRESS/backend -H "Host: app1.domain.com"
app1-backend
```

Test `app2` and `app3`:

```
curl http://$ELB_ADDRESS -H "Host: app2.domain.com"
app2
curl http://$ELB_ADDRESS -H "Host: app3.domain.com"
app3
```

## Extra configuration

There are many [configuration options](https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress#configuration) available that will not be covered here, many of which could be very important in a live environment. [Here is example configuration](https://github.com/deliveryhero/dhh-system-engineering/blob/master/kubernetes/examples/ingress/nginx-ingress-config.yaml) that could be applied when creating the nginx-ingress:

```
curl https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/nginx-ingress-config.yaml -o nginx-ingress-config.yaml
helm install stable/nginx-ingress --name ingress1 -f nginx-ingress-config.yaml
```

This configuration will:

- Ensure there is 2 pods for the default backend running
- Run the controller as a DaemonSet on cluster nodes
- Terminate SSL on the ELB using a certificate from ACM
- Automatically create a DNS record for the ELB in Route53 using [ExternalDNS](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/external-dns)
- Set `publish-service` option so that ExternalDNS records are created correctly
