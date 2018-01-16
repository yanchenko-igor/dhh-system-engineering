# AWS SSO using Google

A Terraform module to create an Identity Provider in IAM and some default roles to be used for SSO.

## Example

```hcl
module "google_sso" {
  source             = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/aws_sso"
  idp_data_file_path = "path/to/GoogleIDPMetadata-my-domain.com.xml"
}
```

## Setup

It is assumed that your G Suite Administrator has already setup the SAML provider and custom user attributes. If not, here is a guide:

https://medium.com/proud2becloud/single-sign-on-with-g-suite-on-the-amazon-web-services-console-d506fda88c90

You need to obtain the `GoogleIDPMetadata` XML file from your G Suite Administrator in order to use this module.

Once the module has been added to your terraform code base and terraform has been run, your G Suite Administrator will also need to add attributes to each Google user in order to allow them access to roles within the AWS account. Once this is all complete, a new application called `Amazon Web Services` will be visible in your Google Apps list, top right corner of a Google web page.
