resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "crl-access-identity"
}

module "cloudfront" {
  count  = var.enable_crl || var.enable_ocsp ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-cloudfront.git?ref=main"

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]
  http_version    = "http2and3"

  origin = [
    {
      domain_name = module.crl_bucket[0].bucket_domain_name
      origin_id   = module.crl_bucket[0].bucket_name
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
      }
    }
  ]

  logging_config = {
    bucket = module.cloudfront_logging_bucket[0].bucket_domain_name
    prefix = "logs"
  }

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

  tags = var.cloudfront_tags
}

module "cloudfront_logging_bucket" {
  count  = var.enable_crl || var.enable_ocsp ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-s3.git?ref=main"

  bucket_name = var.cloudfront_logging_bucket
  kms_key_arn = aws_kms_key.this[0].arn
}