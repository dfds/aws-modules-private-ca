module "crl_bucket" {
  count  = var.enable_crl ? 1 : 0
  source = "git::https://github.com/dfds/aws-modules-s3.git?ref=main"

  bucket_name                     = var.bucket_name
  bucket_versioning_configuration = "Enabled"
  object_ownership                = "BucketOwnerPreferred"
  create_policy                   = false

  kms_key_arn = aws_kms_key.this[0].arn

}

resource "aws_s3_bucket_policy" "this" {
  count  = var.enable_crl ? 1 : 0
  bucket = module.crl_bucket[0].bucket_name
  policy = data.aws_iam_policy_document.bucket[0].json
}

data "aws_iam_policy_document" "bucket" {
  count = var.enable_crl ? 1 : 0

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
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "StringEquals"
      values   = [aws_acmpca_certificate_authority.this.arn]
      variable = "aws:SourceArn"
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

  # Allow OAI access - https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-access-to-amazon-s3/
  statement {
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
      type        = "AWS"
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.crl_bucket[0].bucket_arn}/*"]
  }
}
