data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "default" {}

provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "default" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "frontend" {
  source = "./modules/terraform-aws-frontend-stack"

  region             = "${data.aws_region.default.name}"
  availability_zones = ["${data.aws_availability_zones.default.names}"]
  subnet_ids         = ["${data.aws_subnet_ids.default.ids}"]
  vpc_id             = "${data.aws_vpc.default.id}"
  ami_id             = "${data.aws_ami.ubuntu.id}"

  user_data = "${file("${path.module}/cloud_init.init")}"
}
