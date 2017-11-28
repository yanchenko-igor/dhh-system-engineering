# Security Monkey

Creates the IAM role and associated policy to run Netflix's [Security Monkey](https://github.com/Netflix/security_monkey).

## Example

```hcl
module "security_monkey" {
  source            = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/security_monkey"
  account_id        = 123456789
  assume_role_name  = "SecurityMonkeyInstanceProfile"
}
```
