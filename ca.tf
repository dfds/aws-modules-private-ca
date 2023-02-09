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
