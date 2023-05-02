module "cloudfront_logs_bucket" {
  count  = var.enable_crl ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-s3.git?ref=v1.3.0"
  providers = {
    aws = aws.crl
  }

  bucket_name                     = var.cloudfront_logs_bucket
  bucket_versioning_configuration = "Enabled"
  object_ownership                = "BucketOwnerPreferred"
  create_policy                   = false

  kms_key_arn = aws_kms_key.this[0].arn

  logging_bucket_name = module.s3_logs_bucket[0].bucket_name
}
