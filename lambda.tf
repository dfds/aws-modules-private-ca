locals {
  lambda_name = "certificate-issuer"
  lambda_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAReadOnly",
    aws_iam_policy.lambda_pca_access[0].arn
  ]
}

resource "aws_lambda_function" "this" {
  count = var.deploy_lambda ? 1 : 0

  function_name    = local.lambda_name
  role             = aws_iam_role.lambda[0].arn
  runtime          = "go1.x"
  filename         = "${path.module}/lambdas/${local.lambda_name}/${local.lambda_name}.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdas/${local.lambda_name}/${local.lambda_name}.zip")
  handler          = "main"
  timeout          = 120
  memory_size      = 512

  environment {
    variables = {
      CA_ARN         = aws_acmpca_certificate_authority.this.arn
      VALIDITY_VALUE = var.ca_certificate_validity
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_iam_role" "lambda" {
  count = var.deploy_lambda ? 1 : 0

  name               = local.lambda_name
  assume_role_policy = data.aws_iam_policy_document.lambda[0].json
}

data "aws_iam_policy_document" "lambda" {
  count = var.deploy_lambda ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.deploy_lambda ? 1 : 0
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 0
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(local.lambda_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.lambda[0].name
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = aws_iam_policy.lambda_pca_access[0].arn
  role       = aws_iam_role.lambda[0].name
}

resource "aws_iam_policy" "lambda_pca_access" {
  count  = var.deploy_lambda ? 1 : 0
  policy = data.aws_iam_policy_document.lambda_pca_access[0].json
}

data "aws_iam_policy_document" "lambda_pca_access" {
  count = var.deploy_lambda ? 1 : 0
  statement {
    sid = "AccessPCA"
    actions = [
      "acm-pca:IssueCertificate",
      "acm-pca:GetCertificate",
      "acm-pca:ListPermissions"
    ]
    resources = [
      aws_acmpca_certificate_authority.this.arn
    ]
  }
}

resource "aws_lambda_invocation" "this" {
  count = var.deploy_lambda ? 1 : 0

  function_name = aws_lambda_function.this[0].function_name
  input         = ""
  triggers = {
    redeployment = sha1(jsonencode([
      aws_lambda_function.this[0].environment
    ]))
  }
}