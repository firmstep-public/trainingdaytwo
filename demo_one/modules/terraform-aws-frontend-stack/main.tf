variable "availability_zones" {
  description = "description"
  type        = "list"
}

variable "region" {
  description = "description"
  default     = "description"
}

variable "vpc_id" {
  description = "description"
  default     = "description"
}

variable "subnet_ids" {
  description = "description"
  default     = "description"
  type        = "list"
}

variable "ami_id" {
  description = ""
}

variable "security_group_ids" {
  description = ""
  type        = "list"
}

variable "tags" {
  description = ""
  type        = "map"
  default     = {}
}

variable "name" {
  description = ""
}

variable "user_data" {
  description = ""
  default     = "#"
}

variable "instance_type" {
  description = ""
  default     = "t2.micro"
}

resource "aws_elb" "this" {
  name               = "${var.name}"
  security_groups    = ["${var.security_group_ids}"]
  availability_zones = ["${var.aws_availability_zones}"]
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}"
  image_id      = "${var.ami_id}"
  instance_type = "${var.instance_type}"
}

resource "aws_autoscaling_group" "this" {
  availability_zones = ["${var.aws_availability_zones}"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template = {
    id      = "${aws_launch_template.this.id}"
    version = "$$Latest"
  }
}
