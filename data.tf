data "aws_caller_identity" "crl_account" {
  provider = aws.crl
}

data "aws_caller_identity" "pca_account" {}

