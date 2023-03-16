module "crl_bucket" {
  count  = var.enable_crl ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-s3.git?ref=v1.2.0"
  providers = {
    aws = aws.crl
  }

  bucket_name                     = var.bucket_name
  bucket_versioning_configuration = "Enabled"
  object_ownership                = "BucketOwnerPreferred"
  create_policy                   = false

  kms_key_arn = aws_kms_key.this[0].arn

  logging_bucket_name   = module.s3_logs_bucket[0].bucket_name

}

resource "aws_s3_bucket_policy" "this" {
  count    = var.enable_crl ? 1 : 0
  provider = aws.crl

  bucket = module.crl_bucket[0].bucket_name
  policy = data.aws_iam_policy_document.bucket[0].json
}

data "aws_iam_policy_document" "bucket" {
  count    = var.enable_crl ? 1 : 0
  provider = aws.crl

  statement {
    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "${module.crl_bucket[0].bucket_arn}/*",
      module.crl_bucket[0].bucket_arn
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.pca_account.account_id]
      variable = "aws:SourceAccount"
    }
  }

  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${module.crl_bucket[0].bucket_arn}/*",
      module.crl_bucket[0].bucket_arn
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      values   = [false]
      variable = "aws:SecureTransport"
    }

    condition {
      test     = "NumericLessThan"
      values   = [1.2]
      variable = "s3:TlsVersion"
    }
  }

  statement {
    sid = "AllowCloudFrontServicePrincipal"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.crl_bucket[0].bucket_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      values   = [module.cloudfront[0].cloudfront_arn]
      variable = "AWS:SourceArn"
    }
  }
}
