variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "dynamodb_short_code_key" {
  type = string
}

variable "environment" {
  type = string
}

variable "shorten_lambda_source_file" {
  type = string
}

variable "redirect_lambda_source_file" {
  type = string
}

variable "shorten_reserved_concurrent_executions" {
  type    = number
  default = -1
}

variable "redirect_reserved_concurrent_executions" {
  type    = number
  default = -1
}

variable "redirect_path_parameter_name" {
  type = string
}
