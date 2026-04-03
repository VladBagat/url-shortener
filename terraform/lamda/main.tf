resource "aws_lambda_function" "shorten" {
  filename      = var.shorten_lambda_filename
  function_name = "shorten"
  role          = aws_iam_role.shorten_lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.14"
}

resource "aws_lambda_function" "redirect" {
  filename      = var.redirect_lambda_filename
  function_name = "redirect"
  role          = aws_iam_role.redirect_lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.14"
}

resource "aws_iam_role" "shorten_lambda_role" {
  name = "shorten_lambda_dynamo"

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
  name = "redirect_lambda_dynamo"

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
  name        = "shorten-lambda-dynamodb-policy"
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
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "redirect_lambda_policy" {
  name        = "redirect-lambda-dynamodb-policy"
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
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
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
