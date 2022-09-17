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
  tags = {
    Name = "${var.env}-public-alb"
  }
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
  tags = {
    Name = "${var.env}-private-alb"
  }
}

