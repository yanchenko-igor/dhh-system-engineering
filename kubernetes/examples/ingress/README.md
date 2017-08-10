# Kubernetes Ingress

The [Ingress resource](https://kubernetes.io/docs/concepts/services-networking/ingress/) provides external access to services within a Kubernetes cluster. While a standard `LoadBalancer` service can also provide this, the Ingress resource has some advantages:

- It can provide access to multiple internal services
- It can load balance and split traffic between multiple internal services
- HTTP path/URI based routing
- Supports TLS

In many cases an `Ingress` resource will be the sole external entry point into a cluster, providing access to many applications within a Kubernetes cluster.

There are many different Ingress controllers available, here we will use this one:

https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress

## Try it

In this example traffic will be split between 3 applications as follows:

1. Traffic for host `app1.domain.com` will go to the `app1` application
2. Traffic for host `app2.domain.com` will go to the `app2` application
3. Traffic for host `app3.domain.com` with path `/frontend` will go to the `app3-frontend` application
4. Traffic for host `app3.domain.com` with path `/backend` will go to the `app3-backend` application

Create the 4 applications:

```
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app1.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app2.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app3-backend.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app3-frontend.yaml
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

Create the ingress controller using [Helm](https://github.com/kubernetes/helm):

```
helm install --name ingress1 stable/nginx-ingress
```

Now there should be 2 more pods created, `nginx-ingress-controller` and `nginx-ingress-default-backend`. An ELB will also be created.

Check the ingress controller was created:

```
kubectl describe ingress test-ingress
...
Events:
  FirstSeen	LastSeen	Count	From			SubObjectPath	Type		Reason	Message
  ---------	--------	-----	----			-------------	--------	------	-------
  1m		1m		1	ingress-controller			Normal		CREATE	Ingress default/test-ingress
  36s		36s		2	ingress-controller			Normal		UPDATE	Ingress default/test-ingress
```

Now create the `Ingress` resource:

```
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/ingress.yaml
```

Get the ELB DNS record from the ingress controller:

```
ELB_ADDRESS=$(kubectl get -o wide service ingress1-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Use the ELB DNS record to test `app1`:

```
curl http://$ELB_ADDRESS/this_is_app1 -H "Host: app1.domain.com"
kubectl logs app1-145361462-j52l1
2017/08/09 16:00:41 .... server: localhost, request: "GET /this_is_app1 HTTP/1.1", host: "app1.domain.com"
```

Test `app2`:

```
curl http://$ELB_ADDRESS/this_is_app2 -H "Host: app2.domain.com"
kubectl logs app2-361171512-x9j95
2017/08/09 16:03:02 .... server: localhost, request: "GET /this_is_app2 HTTP/1.1", host: "app2.domain.com"
```

Test `app3-frontend`:

```
curl http://$ELB_ADDRESS/frontend/xx -H "Host: app3.domain.com"
kubectl logs app3-frontend-609358164-tk6kt
2017/08/10 08:10:01 .... server: localhost, request: "GET /frontend/xx HTTP/1.1", host: "app3.domain.com"
```

Test `app3-backend`:

```
curl http://$ELB_ADDRESS/backend/xx -H "Host: app3.domain.com"
kubectl logs app3-frontend-609358164-tk6kt
2017/08/10 08:11:25 .... server: localhost, request: "GET /backend/xx HTTP/1.1", host: "app3.domain.com"
```
