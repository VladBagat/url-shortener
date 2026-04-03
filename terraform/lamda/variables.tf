variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "shorten_lambda_filename" {
  type = string
}

variable "redirect_lambda_filename" {
  type = string
}

variable "shorten_reserved_concurrent_executions" {
  type    = number
  default = 2
}

variable "redirect_reserved_concurrent_executions" {
  type    = number
  default = 2
}

variable "redirect_path_parameter_name" {
  type = string
}
