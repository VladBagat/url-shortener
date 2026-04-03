output "shorten_invoke_arn" {
  value = aws_lambda_function.shorten.invoke_arn
}

output "shorten_function_name" {
  value = aws_lambda_function.shorten.function_name
}

output "redirect_invoke_arn" {
  value = aws_lambda_function.redirect.invoke_arn
}

output "redirect_function_name" {
  value = aws_lambda_function.redirect.function_name
}
