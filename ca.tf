resource "aws_acmpca_certificate_authority" "this" {
  certificate_authority_configuration {
    key_algorithm     = var.key_algorithm
    signing_algorithm = var.signing_algorithm
    subject {
      common_name         = var.common_name
      country             = var.country
      locality            = var.locality
      organization        = var.organization
      organizational_unit = var.organizational_unit
      state               = var.state
    }
  }

  type       = var.ca_type
  usage_mode = var.usage_mode

  dynamic "revocation_configuration" {
    for_each = var.enable_crl || var.enable_ocsp ? ["OK"] : []

    content {
      dynamic "crl_configuration" {
        for_each = var.enable_crl ? ["OK"] : []

        content {
          custom_cname       = module.cloudfront[0].domain_name
          enabled            = var.enable_crl
          expiration_in_days = var.expiration_in_days
          s3_bucket_name     = var.bucket_name
          s3_object_acl      = var.s3_object_acl
        }
      }

      dynamic "ocsp_configuration" {
        for_each = var.enable_ocsp ? ["OK"] : []

        content {
          enabled           = var.enable_ocsp
          ocsp_custom_cname = var.ocsp_custom_cname
        }
      }
    }
  }

  tags = var.private_ca_tags
}

resource "aws_acmpca_policy" "this" {
  policy       = data.aws_iam_policy_document.acmpca.json
  resource_arn = aws_acmpca_certificate_authority.this.arn
}

data "aws_iam_policy_document" "acmpca" {
  dynamic "statement" {
    for_each = var.deploy_lambda ? ["OK"] : []

    content {
      sid = "IssueCertificate"
      principals {
        identifiers = [data.aws_caller_identity.current.account_id]
        type        = "AWS"
      }
      actions = [
        "acm-pca:IssueCertificate"
      ]
      resources = [aws_acmpca_certificate_authority.this.arn]
      condition {
        test     = "StringEquals"
        values   = ["arn:aws:acm-pca:::template/EndEntityCertificate/V1"]
        variable = "acm-pca:TemplateArn"
      }
    }
  }
}

#resource "aws_route53_record" "this" {
#  count = var.enable_ocsp ? 1 : 0
#
#  name    = var.record_name
#  type    = "CNAME"
#  zone_id = var.zone_id
#}

