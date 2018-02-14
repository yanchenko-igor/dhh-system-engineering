data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

# Go here to find the other AMIs: https://cloud-images.ubuntu.com/locator/ec2/
data "aws_ami" "ubuntu_xenial_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
