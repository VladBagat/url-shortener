variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "dynamodb_short_code_key" {
  type = string
}

variable "shorten_function_name" {
  type = string
}

variable "redirect_function_name" {
  type = string
}

variable "shorten_role_name" {
  type = string
}

variable "redirect_role_name" {
  type = string
}

variable "shorten_policy_name" {
  type = string
}

variable "redirect_policy_name" {
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
