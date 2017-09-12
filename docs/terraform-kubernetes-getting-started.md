# Getting started with Kubernetes on AWS

In this guide we will create a Kubernetes cluster on AWS, all associated resources and deploy an application. The result will have the following features:

- Good base AWS design
- SSH bastion
- Pubic Route53 domain
- Kubernetes ingress with ELB and SSL termination
- New Kubernetes resources automatically create DNS records
- Autoscaling of Kubernetes pods
- Autoscaling of Kubernetes cluster nodes
- Helm for easy deployment of Kubernetes applications and components

### Create AWS resources using Terraform

#### Initial customisation

We will create everything in the direcory `terraform/aws/examples/tf-kubernetes-example`.

First let's start with the example in `terraform/aws/examples/kubernetes`, copy it into our directory:

```
mkdir -p terraform/aws/examples/tf-kubernetes-example
cp -a terraform/aws/examples/kubernetes terraform/aws/examples/tf-kubernetes-example/terraform
```

In `terraform/aws/examples/tf-kubernetes-example/terraform/variables.tf` set your AWS region and `office_ips` in `variables.tf`.

We will create a single Kubernetes cluster so remove `cluster2` from `terraform/aws/examples/tf-kubernetes-example/terraform/kubernetes_clusters.tf`

As we will use node autoscaling, we will set the Kubernetes cluster `node_asg_desired` and `node_asg_min` to `1` in `terraform/aws/examples/tf-kubernetes-example/terraform/kubernetes_clusters.tf`.

If you are starting with a completely fresh AWS account you may need to create an EC2 SSH key. The Terraform code here uses the key name `default-key`.

Configure AWS credentials and initialise Terraform:

```
export AWS_ACCESS_KEY_ID=AKIAJJJJJJJJJJJJ
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX
terraform init
```

#### DNS and SSL setup

A real domain in Route53 is required.

Set a real domain in `terraform/aws/examples/tf-kubernetes-example/terraform/route53.tf`. This needs to be an actual domain that you own as it needs to resolve publicly for the certificates created by Kubernetes to be valid. Registering a new domain in the Route53 console is cheap and easy. Or you can import an existing Route53 domain using terraform:

```
terraform import aws_route53_zone.external_zone ZONE_ID_HERE
```

Next we need an SSL certificate in AWS. If you have one already then import it as show [here](http://docs.aws.amazon.com/acm/latest/userguide/import-certificate-api-cli.html). Or create one for free in the [AWS ACM](https://eu-west-1.console.aws.amazon.com/acm/). Note the ARN of the certificate for later steps.


#### Run Terraform

Once the initial customisation is complete, we can run `terraform apply` to create all the resources in AWS.

When this is complete, uncomment the lines in `terraform/aws/examples/tf-kubernetes-example/terraform/terraform.tf` under the `terraform` resource to enable remote Terraform state storage in an S3 bucket. You can get the bucket name from the output of `terraform state show aws_s3_bucket.terraform_state`. Then run `terraform init` and answer `yes` to copy the local state to the S3 bucket. From now on the Terraform state will be synced with this bucket.

#### Verify Kubernetes cluster is healthy

After all the AWS resources have been created and the Kubernetes master and node instances have started there should be a healthy cluster with 3 masters and a single node.

Ensure that the master ELB has all instances `InService`:

```
aws elb describe-instance-health --load-balancer-name cluster1-master
{
    "InstanceStates": [
        {
            "InstanceId": "i-0xxxxxxxxxxxxxx",
            "ReasonCode": "N/A",
            "State": "InService",
            "Description": "N/A"
        },
        {
            "InstanceId": "i-0xxxxxxxxxxxxxx",
            "ReasonCode": "N/A",
            "State": "InService",
            "Description": "N/A"
        },
        {
            "InstanceId": "i-0xxxxxxxxxxxxxx",
            "ReasonCode": "N/A",
            "State": "InService",
            "Description": "N/A"
        }
    ]
}
```

And verify you can communicate with the cluster:

```
kubectl cluster-info
Kubernetes master is running at https://api.cluster1.my-domain.com
KubeDNS is running at https://api.cluster1.my-domain.com/api/v1/namespaces/kube-system/services/kube-dns/proxy

kubectl get nodes -l kubernetes.io/role=master
NAME                                         STATUS    AGE       VERSION
ip-172-20-1-194.eu-west-1.compute.internal   Ready     4m        v1.7.0
ip-172-20-3-31.eu-west-1.compute.internal    Ready     4m        v1.7.0
ip-172-20-5-58.eu-west-1.compute.internal    Ready     5m        v1.7.0

kubectl get nodes -l kubernetes.io/role=node
NAME                                         STATUS    AGE       VERSION
ip-172-20-5-121.eu-west-1.compute.internal   Ready     2m        v1.7.0
```

### Create Kubernetes resouces

Now we come to configuring the Kubernetes cluster.

#### Autoscaling of cluster nodes and pods

There is more detail about enabling autoscaling [here](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/autoscaling).

The monitoring add on is required for pod autoscaling:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml
```

Set up the node autoscaler as detailed [here](https://github.com/kubernetes/kops/tree/master/addons/cluster-autoscaler).

```
CLOUD_PROVIDER=aws
IMAGE=gcr.io/google_containers/cluster-autoscaler:v0.6.0
MIN_NODES=1
MAX_NODES=20
AWS_REGION=eu-west-1
GROUP_NAME="cluster1_node"
SSL_CERT_PATH="/etc/ssl/certs/ca-certificates.crt"

addon=cluster-autoscaler.yml
wget -O ${addon} https://raw.githubusercontent.com/kubernetes/kops/master/addons/cluster-autoscaler/v1.6.0.yaml

sed -i -e "s@{{CLOUD_PROVIDER}}@${CLOUD_PROVIDER}@g" "${addon}"
sed -i -e "s@{{IMAGE}}@${IMAGE}@g" "${addon}"
sed -i -e "s@{{MIN_NODES}}@${MIN_NODES}@g" "${addon}"
sed -i -e "s@{{MAX_NODES}}@${MAX_NODES}@g" "${addon}"
sed -i -e "s@{{GROUP_NAME}}@${GROUP_NAME}@g" "${addon}"
sed -i -e "s@{{AWS_REGION}}@${AWS_REGION}@g" "${addon}"
sed -i -e "s@{{SSL_CERT_PATH}}@${SSL_CERT_PATH}@g" "${addon}"

kubectl apply -f ${addon}
serviceaccount "cluster-autoscaler" created
clusterrole "cluster-autoscaler" created
role "cluster-autoscaler" created
clusterrolebinding "cluster-autoscaler" created
rolebinding "cluster-autoscaler" created
deployment "cluster-autoscaler" created
```

#### Auto creation of DNS records for Kubernetes resources

For this we use the [ExternalDNS](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md). The IAM permissions and Route53 domain are already setup so we just need to create the Kubernetes deployment for this tool:

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

There should now be a pod running:

```
kubectl get pods -l app=external-dns
NAME                            READY     STATUS    RESTARTS   AGE
external-dns-1999566577-w6jdg   1/1       Running   0          1m
```

#### Install Helm

Very simple:

```
brew install kubernetes-helm
helm init
```

You should then have a new pod running:

```
$ kubectl get pods -n kube-system -l app=helm
NAME                             READY     STATUS    RESTARTS   AGE
tiller-deploy-1651615695-qpb0k   1/1       Running   0          1m
```

#### Create an Ingress controller

An Ingress controller will allow us to create [Ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/) in Kubernetes. [Here](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/ingress) is an example showing how an Ingress resource works and why it is useful. We will use the [nginx-ingress controller](https://github.com/kubernetes/ingress/tree/master/controllers/nginx).

Get a configuration file for the controller:

```
curl https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/nginx-ingress-config.yaml -o nginx-ingress-config.yaml
```

Update values in `nginx-ingress-config.yaml` with your Route53 domain and SSL certificate ARN from ACM.

Install the nginx-ingress controller:

```
helm install stable/nginx-ingress --name ingress1 -f nginx-ingress-config.yaml
```

You should then have new pods running:

```
kubectl get pods -l app=nginx-ingress
NAME                                                      READY     STATUS    RESTARTS   AGE
ingress1-nginx-ingress-controller-8pp5h                   1/1       Running   0          5m
ingress1-nginx-ingress-default-backend-4255036803-mrj5g   1/1       Running   0          5m
ingress1-nginx-ingress-default-backend-4255036803-n2z3s   1/1       Running   0          5m
```

And the nginx-ingress controller should create an ELB which should have all Kubernetes cluster nodes `InService`.

### Deploy an application

We will deploy `app1` from the [ingress example](https://github.com/deliveryhero/dhh-system-engineering/tree/master/kubernetes/examples/ingress), which includes a frontend and backend web application.

Create the 2 application components, frontend and backend:

```
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app1-backend.yaml
kubectl apply -f https://raw.githubusercontent.com/deliveryhero/dhh-system-engineering/master/kubernetes/examples/ingress/app1-frontend.yaml
```

Now there should be 2 pods running:

```
kubectl get pods
NAME                                                      READY     STATUS    RESTARTS   AGE
app1-backend-328254284-pff0b                              1/1       Running   0          22m
app1-frontend-1695000296-14kmc                            1/1       Running   0          22m
```

Create an ingress resource so we can access the 2 application components via the ingress ELB:

```
cat <<EOF | kubectl create -f -

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: app1
spec:
  rules:
  - host: app1.my-domain.com
    http:
      paths:
      - path: /frontend
        backend:
          serviceName: app1-frontend
          servicePort: 80
      - path: /backend
        backend:
          serviceName: app1-backend
          servicePort: 80

EOF
```

Ensure that the DNS record for `app1.my-domain.com` is created, HTTPS works and that the application is accessible:

```
curl https://app1.my-domain.com/backend
app1-backend
curl https://app1.my-domain.com/frontend
app1-frontend
```

Now add horizontal pod autoscaling to the application:

```
kubectl autoscale deployment app1-frontend --min=1 --max=20 --cpu-percent=20
```

Test the horizontal pod autoscaling by stressing `app1-frontend` the `ab` tool:

```
ab -n 99999 -c 50 http://app1.my-domain.com/frontend
```

And then observe the HPA CPU utilisation increase and new pods created:

```
kubectl get hpa
NAME            REFERENCE                  TARGETS     MINPODS   MAXPODS   REPLICAS   AGE
app1-frontend   Deployment/app1-frontend   49% / 20%   1         20        3          6m

kubectl get pods -l name=app1-frontend
NAME                             READY     STATUS    RESTARTS   AGE
app1-frontend-1695000296-14kmc   1/1       Running   0          3h
app1-frontend-1695000296-39z7l   1/1       Running   0          1m
app1-frontend-1695000296-3zt4v   1/1       Running   0          1m
```
