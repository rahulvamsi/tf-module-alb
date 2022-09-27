resource "aws_lb" "public" {
  name               = "roboshop-${var.env}-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = var.public_subnets

  tags = {
    Environment = "roboshop-${var.env}-public"
  }
}

resource "aws_lb_target_group" "public" {
  name                 = "frontend-${var.env}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    timeout             = 4
    port                = 80
    unhealthy_threshold = 2
    path                = "/nginx_status"
  }
}

resource "aws_lb_listener" "public-https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.public.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

resource "aws_lb_listener" "public-http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env}-public-alb"
  description = "${var.env}-public-alb"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-public-alb"
  }
}

resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.public.id
  name    = var.PUBLIC_DNS_RECORD
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.public.dns_name]
}

resource "aws_lb" "private" {
  name               = "roboshop-${var.env}-private"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private.id]
  subnets            = var.app_subnets

  tags = {
    Environment = "roboshop-${var.env}-private"
  }
}

resource "aws_lb_listener" "private" {
  load_balancer_arn = aws_lb.private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}


resource "aws_security_group" "private" {
  name        = "${var.env}-private-alb"
  description = "${var.env}-private-alb"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-private-alb"
  }
}

