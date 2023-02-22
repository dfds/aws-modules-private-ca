data "aws_caller_identity" "current" {
  provider = aws.crl
}

data "aws_caller_identity" "pca_account" {}