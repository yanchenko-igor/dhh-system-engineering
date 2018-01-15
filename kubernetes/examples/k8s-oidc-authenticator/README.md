# Kubernetes OpenID Connect authenticator

Kubernetes provides various methods to [authenticate against the API](https://kubernetes.io/docs/admin/authentication/), here we will use OpenID Connect (OIDC) authentication with RBAC enabled.

Credit to [cu12](https://github.com/cu12/k8s-oidc-helper) for this adaptation of the original k8s-oidc-helper from micahhausler: https://github.com/micahhausler/k8s-oidc-helper

## Installation

#### Create OAuth credentials

You need a Google Cloud project.

  1. Go to https://console.cloud.google.com/apis/credentials
  2. Click `Create credentials` > `OAuth client ID` > `Web application`
  3. Choose a name. e.g. `k8s-oidc-authenticator`
  4. Enter a URL in `Authorized redirect URIs`. e.g. https://oidc-auth.my-domain.com/callback
  5. Record the `Client ID` and `Client secret` for later

#### Configure Kubernetes API for OIDC

To configure the Kubernetes API server you need to add some parameters. This is detailed here: https://kubernetes.io/docs/admin/authentication/#configuring-the-api-server

If you used [kops](https://github.com/kubernetes/kops) to build your Kubernetes cluster, you can edit it like this:

```
kops edit cluster --name cluster.my-domain.com
```

And insert these lines:

```yaml
spec:
  api:
    kubeAPIServer:
      authorizationMode: RBAC
      oidcClientID:  <Client ID from GCP>
      oidcIssuerURL: https://accounts.google.com
      oidcUsernameClaim: email
```

If you don't have the `kubeAPIServer` section, create it.

#### Create Kubernetes resources

There is a Helm chart in `kubernetes/examples/k8s-oidc-authenticator/helm-chart` that will create:

  - A deployment and service for the k8s-oidc-authenticator container
  - Ingress resource
  - RoleBinding and ClusterRoleBinding to allow admin access or access to specific namespaces

Here is an example values file to be passed to the Helm chart:

```yaml
ingress:
  # Hostname used for the ingress resource
  hostname: k8s-oauth.my-domain.com
  # Optionally white list IPs on the Ingress resource
  whitelist_ips:
    - 201.1.2.3
    - 184.1.2.3

oidc:
  # These values are from the API & Services page of GCP
  client_id: "2222222-xxxxxx.apps.googleusercontent.com"
  client_secret: "xxxxxxx"
  allowed_domain: my-org.com

role_bindings:
  # Email addresses given admin access
  cluster-admin:
    - user1@my-domain.com
    - user2@my-domain.com
  namespaces:
    # Email addresses given access to specific namespaces
    default:
      - user3@my-domain.com
      - user4@my-domain.com
```

Install the chart:

```
helm install kubernetes/examples/k8s-oidc-authenticator/helm-chart --name k8s-oidc-authenticator -f my-k8s-oidc-authenticator-values.yaml
```

## Use

Simply open your configured ingress hostname, `ingress.hostname` from above, in your browser and you will be redirected to Google for authentication. If your email address matches one of from `role_bindings` section of the configuration, you will see the required `kubectl` commands in order to connect to the cluster.
