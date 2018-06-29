output "security_group_id" {
  value = "${aws_security_group.this.id}"
}

output "elb_security_group_id" {
  value = "${aws_security_group.this_elb.id}"
}

output "lb_dns_name" {
  value = "${aws_lb.this.dns_name}"
}
