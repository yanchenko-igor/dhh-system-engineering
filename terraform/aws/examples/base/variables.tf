variable "aws_region" {
  default = "eu-west-1"
}

variable "office_ips" {
  # Update with your trusted IP addresses
  type    = "list"
  default = [
    "100.1.1.0/26",
    "100.1.2.0/29",
    "100.1.3.0/29",
    "100.1.4.0/29"
  ]
}
