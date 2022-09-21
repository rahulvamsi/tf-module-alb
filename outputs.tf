output "public_tg_arn" {
  value = aws_lb_target_group.public.arn
}

output "private_lb_dns_name" {
  value = aws_lb.private.dns_name
}

output "private_lb_listener_arn" {
  value = aws_lb_listener.private.arn
}
