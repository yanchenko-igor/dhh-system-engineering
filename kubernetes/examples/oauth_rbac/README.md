# Kubernetes OAUTH and RBAC

The [Kubernetes authentication](https://kubernetes.io/docs/admin/authentication/) provides some methods to authenticate against the API: X509 Client Certs, Static Token File, Static Password File, Service Account Tokens, but for our proposal we are going to use OIDC authentication.

#### Try it

Configure the Kubeapi-server, if you are using our example with Kops and Terraform you should try something like this:

```
kops edit cluster --name cluster.mydomain.com --state s3://BUCKET-STATE
```

And insert this lines to the configuration:
```
...
kubeAPIServer:
    authorizationMode: RBAC
    oidcClientID:  <CLIENT-ID>
    oidcIssuerURL: https://accounts.google.com
    oidcUsernameClaim: email
...  
```
If you don't have the `kubeAPIServer` section, create it.

<dl>
  <dt>*Describe*</dt>
  <dd>**authorizationMode:** Role Based Access Control, it will give us the flexibility to create the profiles.  
  **oidcClientID:** This should be created in the Google API.  
  **oidcIssuerURL:** Default  
  **oidcUsernameClaim:** This is what Kube is gooing to looking.
  </dd>
</dl>

Save the file and restart the cluster as you wish.

#### Creating the new ~/.kube/config

<dl>
  <dd>

  *** If you already have a production environment you should try this helm chart made by ***
  [Max Williams](https://github.com/deliveryhero/dhh-system-engineering/)

  </dd>
</dl>

Now we need to create our new kubectl, for this we are going to use this [helper](https://github.com/micahhausler/k8s-oidc-helper)



Run it:
```
k8s-oidc-helper -c ./client_secret.json* --write
Enter the code Google gave you: <code>

Configuration has been written to ~/.kube/config
```
<dl>
  <dd>
  ***client_secret.json:*** This file need to be downloaded from the Google API or you could get from your System engineering Team.  
  ***write:*** Will write the config to your ˜/.kube/config
  </dd>
</dl>

To have a clean access lets configure the context and the server.
```
kubectl config set-context test --cluster cluster.mydomain.com --user USER@EMAIL.com --server=https://CLUSTER
```

And configure the SERVER:
```
kubectl config set-cluster cluster.mydomain.com --insecure-skip-tls-verify=true --server=https://CLUSTER
```

If you are the administrator of the cluster this example role will give full access to the USER@email.com
```
kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=USER@EMAIL.com
```
You can find lots of information on how to configure you RBAC here:
```
https://kubernetes.io/docs/admin/authorization/rbac/#rolebinding-and-clusterrolebinding
```


If you are the user, test it!
```
kubectl get nodes
```
