resource "aws_lb" "publb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.public-alb-tg.id}"]
  subnets            = ["${var.pub1subnet}","${var.pub2subnet}"]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "publictg" {
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

resource "aws_security_group" "public-alb-tg" {
  vpc_id = "${var.vpc}"
}

resource "aws_security_group_rule" "inbound_http_allow" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public-alb-tg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_http_allow" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public-alb-tg.id}"
  to_port           = 80
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_configuration" "public_lc" {
  image_id = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.public-alb-tg.id}"]
  user_data = "${file("${path.cwd}\\${path.module}\\public_nginx.sh")}"
  key_name = "${var.keyname}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "public_asg" {
  max_size = 2
  min_size = 0
  desired_capacity = 2

  launch_configuration = "${aws_launch_configuration.public_lc.name}"
  
  target_group_arns = ["${aws_lb_target_group.publictg.id}"]
  vpc_zone_identifier = ["${var.pub1subnet}","${var.pub2subnet}"]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "public" {
  load_balancer_arn = "${aws_lb.publb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.publictg.arn}"
  }
}
