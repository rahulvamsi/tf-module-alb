data "aws_route53_zone" "public" {
  name         = "rahulsdevops.online"
  private_zone = false
}

data "aws_acm_certificate" "public" {
  domain   = "*.rahulsdevops.online"
  statuses = ["ISSUED"]
}


