resource "aws_dynamodb_table" "links" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "short_link"

  attribute {
    name = "short_link"
    type = "S"
  }
}