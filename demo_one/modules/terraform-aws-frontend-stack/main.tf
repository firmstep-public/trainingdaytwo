resource "aws_lb" "this" {
  name_prefix        = "${substr(var.name, 0 , 6)}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.this_elb.id}"]
  subnets            = ["${var.subnet_ids}"]

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = "${var.tags}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "this" {
  name_prefix = "${substr(var.name, 0 , 6)}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  tags        = "${var.tags}"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.this.arn}"
    type             = "forward"
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.name}"
  image_id               = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  tags                   = "${var.tags}"
  user_data              = "${base64encode(var.user_data)}"
  key_name               = "${module.ssh_key_pair.key_name}"

  instance_market_options {
    market_type = "spot"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = "${var.tags}"
  }
}

resource "aws_autoscaling_group" "this" {
  availability_zones = ["${var.availability_zones}"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  target_group_arns = ["${aws_lb_target_group.this.arn}"]

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
  security_group_id = "${aws_security_group.this_elb.id}"
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
  source_security_group_id = "${aws_security_group.this_elb.id}"
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

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace             = "cp"
  stage                 = "prod"
  name                  = "${var.name}"
  ssh_public_key_path   = "${path.module}/secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}
