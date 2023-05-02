module "cloudfront" {
  count     = var.enable_crl || var.enable_ocsp ? 1 : 0
  source    = "git::https://github.com/dfds/aws-modules-cloudfront.git?ref=v1.0.1"
  providers = { aws = aws.crl }

  allowed_methods = ["GET", "HEAD", "OPTIONS"]
  cached_methods  = ["GET", "HEAD"]
  http_version    = "http2and3"

  origin = [
    {
      domain_name              = module.crl_bucket[0].bucket_domain_name
      origin_id                = module.crl_bucket[0].bucket_name
      origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
    }
  ]

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
      locations        = []
    }
  }

  target_origin_id       = module.crl_bucket[0].bucket_name
  viewer_protocol_policy = "redirect-to-https"

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  logging_config = {
    bucket = module.cloudfront_logs_bucket[0].bucket_domain_name
    prefix = "cloudfront-logs/"
  }

  tags = var.cloudfront_tags
}

resource "aws_cloudfront_origin_access_control" "this" {
  count    = var.enable_crl ? 1 : 0
  provider = aws.crl

  name                              = var.cloudfront_origin_access_control_name
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}
