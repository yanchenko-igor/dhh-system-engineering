# Helm example

[Helm](https://github.com/kubernetes/helm) allows the creation of reusable templates for Kubernetes resources. This can help create consistent and repeatable builds across environments.

Here is a simple example using Helm with templates for a deployment and service.

## Try it

First you need to have helm installed on your own computer and tiller installed on the Kubernetes cluster.

Mac instructions:

```
brew install kubernetes-helm
helm init
```

For other platforms, see the [quickstart-guide](https://docs.helm.sh/using_helm/#quickstart-guide)

Run a Redis container:

```
helm install kubernetes/examples/helm/generic-deployment-service --name "myapp-redis" --set image.repository=redis --set service.port=6379 --set image.tag=3.2-alpine --set service_name="myapp"
```

Run a Memcached container:

```
helm install kubernetes/examples/helm/generic-deployment-service --name "myapp-memcached" --set image.repository=memcached --set service.port=11211 --set image.tag=1-alpine --set service_name="myapp"
```

Run a RabbitMQ container:

```
helm install kubernetes/examples/helm/generic-deployment-service --name "myapp-rabbitmq" --set image.repository=rabbitmq --set service.port=5672 --set image.tag=3.6.10 --set service_name="myapp"
```

## Other helm charts

Helm is a very powerful tool and many useful and stable examples exist already in the Kubernetes project:

https://github.com/kubernetes/charts
