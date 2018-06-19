locals {
  node_auth_config_map = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
}

resource "null_resource" "node_auth_update" {
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF | KUBECONFIG=${var.kubeconfig_path} kubectl apply -f -
${local.node_auth_config_map}
EOF
EOD
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "KUBECONFIG=${var.kubeconfig_path} kubectl -n kube-system delete configmap aws-auth"
  }
}
