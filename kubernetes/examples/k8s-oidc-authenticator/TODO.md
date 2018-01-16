# To do

- Update container to restrict access to a selection of single email addresses instead of whole domain
- Review security of code used in container
- Customise colours/look of output
- Remove `client_secret` when it's no longer required. Should be [soon](https://github.com/kubernetes/kubernetes/issues/37822#issuecomment-355601117)
- Add kubectl context config commands to output
- Switch to use secret instead of env vars
- Move to kube-system namespace so deployment can only be changed my admin
