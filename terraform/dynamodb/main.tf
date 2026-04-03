locals {
  table_name     = "links-${var.environment}"
  short_code_key = "short_link"
}

resource "aws_dynamodb_table" "links" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = local.short_code_key

  attribute {
    name = local.short_code_key
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
