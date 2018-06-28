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
  type        = "list"
}

variable "ami_id" {
  description = ""
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

  instance_market_options {
    market_type = "spot"
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = ["${aws_security_group.this.id}"]
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

resource "aws_security_group" "this" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.name}-instance-sg"

  tags = "${var.tags}"
}

resource "aws_security_group" "this_elb" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.name}-elb-sg"

  tags = "${var.tags}"
}

resource "aws_security_group_rule" "allow_access_out_elb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "allow_access_out_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "allow_http_instance" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = ["${aws_security_group.this_elb.id}"]
  security_group_id        = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "allow_https_elb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this_elb.id}"
}

resource "aws_security_group_rule" "allow_http_elb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this_elb.id}"
}

output "security_group_id" {
  value = "${aws_security_group.this.id}"
}
