// Configure AWS provider
variable "sso-account" {
  default = "123456789098"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "company" {
  default = "deliveryhero"
}

variable "administrator_default_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "developer_default_arn" {
  default = "arn:aws:iam::aws:policy/PowerUserAccess"
}
