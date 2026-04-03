output "table_name" {
  value = aws_dynamodb_table.links.name
}

output "table_arn" {
  value = aws_dynamodb_table.links.arn
}

output "short_code_key" {
  value = local.short_code_key
}
