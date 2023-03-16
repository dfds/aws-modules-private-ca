module "s3_logs_bucket" {
  count  = var.enable_crl ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-s3.git//s3-logging-bucket?ref=v1.2.0"
  providers = {
    aws = aws.crl
  }

  bucket_name                     = var.s3_logs_bucket
  source_buckets = [
    {
      source_bucket_arn = module.crl_bucket[0].bucket_arn
      logs_prefix = "${module.crl_bucket[0].bucket_name}/"
    },
    {
      source_bucket_arn = module.cloudfront_logs_bucket[0].bucket_arn
      logs_prefix = "${module.cloudfront_logs_bucket[0].bucket_name}/"
    }
  ]
}
