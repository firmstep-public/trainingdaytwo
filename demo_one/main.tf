data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "default" {}

provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "default" {}

data "aws_ami" "drupal" {
  most_recent = true

  filter {
    name   = "name"
    values = ["drupal8_lemp7_g2-180531-amazonlinux-2018.03.0--jetware-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Jetware
}

module "frontend" {
  source = "./modules/terraform-aws-frontend-stack"

  region             = "${data.aws_region.default.name}"
  availability_zones = ["${data.aws_availability_zones.default.names}"]
  subnet_ids         = ["${data.aws_subnet_ids.default.ids}"]
  vpc_id             = "${data.aws_vpc.default.id}"
  ami_id             = "${data.aws_ami.drupal.id}"
  name               = "frontend"
  user_data          = "${file("${path.module}/cloud_init.init")}"

  tags = {
    Name            = "frontend"
    Stage           = "Dev"
    Owner           = "Jamie"
    Favorite_animal = "Snake"
  }
}

output "security_group_id" {
  value = "${module.frontend.security_group_id}"
}

output "elb_security_group_id" {
  value = "${module.frontend.elb_security_group_id}"
}

output "lb_dns_name" {
  value = "${module.frontend.lb_dns_name}"
}

output "website" {
  value = "http://${module.frontend.lb_dns_name}"
}
