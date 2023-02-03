resource "aws_kms_key" "this" {
  count = var.create_kms ? 1 : 0

  description             = "KMS key for private CA "
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms[count.index].json
  enable_key_rotation     = var.enable_key_rotation
}

resource "aws_kms_alias" "this" {
  count = var.create_kms ? 1 : 0

  name          = format("alias/%s", var.kms_key_alias)
  target_key_id = aws_kms_key.this[count.index].key_id
}

data "aws_iam_policy_document" "kms" {
  count = var.create_kms ? 1 : 0

  statement {
    sid = "AllowPCA"
    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["arn:aws:s3:::${var.bucket_name}"]
      variable = "kms:EncryptionContext:aws:s3:arn"
    }
  }

  dynamic "statement" {
    for_each = var.enable_kms_default_policy ? ["OK"] : []

    content {
      sid       = "DefaultPolicy"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_administrators) > 0 ? ["OK"] : []

    content {
      sid = "KeyAdmin"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ]
      resources = ["*"]

      principals {
        identifiers = var.kms_key_administrators
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_users) > 0 ? ["OK"] : []

    content {
      sid = "KeyUser"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      resources = ["*"]

      principals {
        identifiers = var.kms_key_users
        type        = "AWS"
      }
    }
  }
}