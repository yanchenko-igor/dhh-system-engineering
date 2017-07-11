# Logging to Splunk via PubSub

Configures PubSub, service account and IAM policy to allow Splunk to pull logs from GKE/GCP.

There is a rerequired Splunk Addon, documentation is here: http://docs.splunk.com/Documentation/AddOns/released/GoogleCloud/Configureinputsv1modular

## Example

```hcl
module "splunk_logging" {
  source       = "./splunk_logging"
  project_name = "my-gcp-project"
}
```
