resource "aws_lb" "internallb" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.private-alb-tg.id}"]
  subnets            = ["${var.priv1subnet}","${var.priv2subnet}"]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "privatetg" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc}"
  target_type = "instance"
}

resource "aws_security_group" "private-alb-tg" {
  vpc_id = "${var.vpc}"
}

resource "aws_security_group_rule" "inbound_vpc" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.private-alb-tg.id}"
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = ["${var.cidr}"]
}

resource "aws_security_group_rule" "outbound_vpc" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.private-alb-tg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["${var.cidr}"]
}
resource "aws_security_group_rule" "outbound_self" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.private-alb-tg.id}"
  to_port           = 0
  type              = "egress"
  self = true
}
resource "aws_launch_configuration" "internal_lc" {
  image_id = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.private-alb-tg.id}"]
  user_data = "${file("${path.cwd}\\${path.module}\\internal_nginx.sh")}"
  key_name = "${var.keyname}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "internal_asg" {
  max_size = 2
  min_size = 0
  desired_capacity = 2

  launch_configuration = "${aws_launch_configuration.internal_lc.name}"
  
  target_group_arns = ["${aws_lb_target_group.privatetg.id}"]
  vpc_zone_identifier = ["${var.priv1subnet}","${var.priv2subnet}"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = "${aws_lb.internallb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.privatetg.arn}"
  }
  
}
