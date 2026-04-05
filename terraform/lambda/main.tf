data "archive_file" "shorten" {
  type        = "zip"
  source_file = var.shorten_lambda_source_file
  output_path = "${path.module}/build/shorten.zip"
}

data "archive_file" "redirect" {
  type        = "zip"
  source_file = var.redirect_lambda_source_file
  output_path = "${path.module}/build/redirect.zip"
}

resource "aws_lambda_function" "shorten" {
  filename                       = data.archive_file.shorten.output_path
  source_code_hash               = data.archive_file.shorten.output_base64sha256
  function_name                  = var.shorten_function_name
  role                           = aws_iam_role.shorten_lambda_role.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.14"
  reserved_concurrent_executions = var.shorten_reserved_concurrent_executions

  environment {
    variables = {
      TABLE_NAME     = var.dynamodb_table_name
      SHORT_CODE_KEY = var.dynamodb_short_code_key
    }
  }
}

resource "aws_lambda_function" "redirect" {
  filename                       = data.archive_file.redirect.output_path
  source_code_hash               = data.archive_file.redirect.output_base64sha256
  function_name                  = var.redirect_function_name
  role                           = aws_iam_role.redirect_lambda_role.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.14"
  reserved_concurrent_executions = var.redirect_reserved_concurrent_executions

  environment {
    variables = {
      TABLE_NAME          = var.dynamodb_table_name
      SHORT_CODE_KEY      = var.dynamodb_short_code_key
      PATH_PARAMETER_NAME = var.redirect_path_parameter_name
    }
  }
}

resource "aws_cloudwatch_log_group" "shorten" {
  name              = "/aws/lambda/${aws_lambda_function.shorten.function_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "redirect" {
  name              = "/aws/lambda/${aws_lambda_function.redirect.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role" "shorten_lambda_role" {
  name = var.shorten_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "redirect_lambda_role" {
  name = var.redirect_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "shorten_lambda_policy" {
  name        = var.shorten_policy_name
  path        = "/"
  description = "IAM policy for shorten Lambda access to DynamoDB and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.shorten.arn}:*"
      }
    ]
  })
}

resource "aws_iam_policy" "redirect_lambda_policy" {
  name        = var.redirect_policy_name
  path        = "/"
  description = "IAM policy for redirect Lambda access to DynamoDB and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem"
        ]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.redirect.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_shorten_policy_to_role" {
  role       = aws_iam_role.shorten_lambda_role.name
  policy_arn = aws_iam_policy.shorten_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_redirect_policy_to_role" {
  role       = aws_iam_role.redirect_lambda_role.name
  policy_arn = aws_iam_policy.redirect_lambda_policy.arn
}
