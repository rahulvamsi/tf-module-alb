data "aws_route53_zone" "public" {
  name         = "devopsb66.online"
  private_zone = false
}

data "aws_acm_certificate" "public" {
  domain   = "*.devopsb66.online"
  statuses = ["ISSUED"]
}


