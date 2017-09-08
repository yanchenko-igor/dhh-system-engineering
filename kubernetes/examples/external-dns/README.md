# Using ExternalDNS

[ExternalDNS](https://github.com/kubernetes-incubator/external-dns) is a tool that will automatically create DNS records in Route53 for Kubernetes resources like services and ingress.

The AWS installation tutorials is [here](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md)

If you are using the [Kubernetes AWS example](terraform/aws/examples/kubernetes) then the IAM Permissions should already be in place and you should already have a working DNS zone in Route53.

Then you just need to apply the YAML Deployment shown [here](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md#deploy-externaldns) and change `--domain-filter` and `--txt-owner-id` and optionally `--policy`.

e.g.

```
cat <<EOF | kubectl create -f -

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:v0.4.2
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=my-domain.com
        - --provider=aws
        - --registry=txt
        - --txt-owner-id=kubernetes_cluster1

EOF
```

Verify ExternalDNS works by following steps [here](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md#verify-externaldns-works).
