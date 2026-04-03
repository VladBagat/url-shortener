locals {
  table_name = "links-${var.environment}"
}

resource "aws_dynamodb_table" "links" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "short_link"

  attribute {
    name = "short_link"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
