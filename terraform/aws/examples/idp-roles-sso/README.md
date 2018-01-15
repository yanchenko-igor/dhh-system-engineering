## Identity Provider and ROLES for SSO

Here you are going to find some examples on how to apply some to create some segmentation inside AWS with Google SSO.

## Steps
1 - Get the metadata from SSO in GoogleApps.  
2 - Create the Identity Provider in the AWS  account with the Metadata  
3 - Create the ROLES for the group of users that you are willing to give access.  
4 - Configure SSO GoogleApps

## Identity Provider example

This example will create for you the *Identity Provider*:
```
resource "aws_iam_saml_provider" "sso-account_gapps" {
  name = "GoogleApps"
  saml_metadata_document = "${file("saml-metadata/GoogleIDPMetada-DOMAIN.xml")}"
  provider = "aws.sso-account"
}
```

Also is possible to do it through CLI:
```
aws iam create-saml-provider --saml-metadata-document file://GoogleIDPMetadata-yourdomain.xml --name GoogleAppsProvider
```


## Roles example:

Example of Administrator Role:
```
resource "aws_iam_role" "infra_ops" {
    provider = "aws.infra"
    name = "Ops"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_policy_attachment" "infra_ops" {
    provider = "aws.infra"
    name = "infra_ops_attachment"
    roles = ["${aws_iam_role.infra_ops.name}"]
    policy_arn = "arn:aws:iam::aws:policy/Administrator"
}
```
Example of a PowerUserAccess Role:
```
resource "aws_iam_role" "infra_dev_admin" {
    provider = "aws.infra"
    name = "DevAdmin"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_policy_attachment" "infra_dev_admin" {
    provider = "aws.infra"
    name = "infra_dev_admin_attachment"
    roles = ["${aws_iam_role.infra_dev_admin.name}"]
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
```

 These ROLES can be applied for a group of users such as Administrators, DevOps, Developers and QA in the GoogleApps.


Tutorial of how to configure your SSO:
[Google Suite and AWS SSO](https://medium.com/proud2becloud/single-sign-on-with-g-suite-on-the-amazon-web-services-console-d506fda88c90)



#### Note
Whatch out for the XML file with the Metadata (don't expose this file, it has the Account ID and Certificate, keep it safe.)
