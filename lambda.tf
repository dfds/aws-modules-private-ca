locals {
  lambda_name = "certificate-issuer"
}

resource "aws_lambda_function" "this" {
  count = var.deploy_lambda ? 1 : 0

  function_name = local.lambda_name
  role          = aws_iam_role.this[0].arn
  runtime       = "go1.x"
  filename      = "/lambdas/${local.lambda_name}/${local.lambda_name}.zip"
  handler       = "main"

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

resource "aws_iam_role" "this" {
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

resource "aws_cloudwatch_log_group" "this" {
  count             = var.deploy_lambda ? 1 : 0
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 0
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.this[0].name
}

resource "aws_lambda_invocation" "this" {
  count = var.deploy_lambda ? 1 : 0

  function_name = aws_lambda_function.this[0].function_name
  input         = ""
  triggers = {
    redeployment = sha1(aws_acmpca_certificate_authority.this.status)
  }
}