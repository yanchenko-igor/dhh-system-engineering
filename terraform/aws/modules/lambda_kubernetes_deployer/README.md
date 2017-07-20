# Lambda Kubernetes Deployer

A lambda function, IAM policy, Cloudwatch event rule and Cloudwatch target to automatically deploy to Kubernetes when a new container image is pushed to an EC2 Container Registry Repository.

## Example

```hcl
module "kubernetes_deployer_cluster1" {
  source                  = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/lambda_kubernetes_deployer"
  name                    = "cluster1"
  aws_ecr_repository_base = "22222222.dkr.ecr.eu-west-1.amazonaws.com"
  kube_config_name        = "cluster1.k8s.yourdomain.com"
}
```

## Creating zip file

The zip file used for the Lambda function needs to have:

- `patch_deployment.py`
- `kube_config`: The YAML file containing the certificates required for authentication to Kubernetes API
- `python-packages`: A directory containing all python package dependencies.

Install the python package dependencies into `python-packages`:

```
docker run -it --volume=$PWD/python-packages:/python-packages python:3.6 bash -c "pip install 'kubernetes==2.0.0' --target=/python-packages"
```

Create the `kube_config` file by copying the data from `~/.kube/config` on your own computer. e.g.

```yaml
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0...
    server: https://cluster1.k8s.yourdomain.com
  name: cluster1.k8s.yourdomain.com
users:
- name: cluster1.k8s.yourdomain.com
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0...
    client-key-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0...
```

Create the zip file:

```
zip -q -r lambda_kubernetes_deployer.zip patch_deployment.py python-packages kube_config
```

Update the function with the zip file:

```
aws lambda update-function-code --function-name kubernetes_deployer_cluster1 --zip-file fileb://lambda_kubernetes_deployer.zip
```

To test the function, push a new docker image tag to an EC2 Container Registry Repository.

## Notes

- Update is made to first container in the deployment so currently deployments with multiple containers are not supported.
- CloudTrail must be enabled.
- The name of the ECR repository must correspond to the name of the Kubernetes deployment.
