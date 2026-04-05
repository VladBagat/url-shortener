variable "stage_throttling_rate_limit" {
  type    = number
  default = 1
}

variable "stage_throttling_burst_limit" {
  type    = number
  default = 2
}

variable "shorten_invoke_arn" {
  type = string
}

variable "shorten_function_name" {
  type = string
}

variable "redirect_invoke_arn" {
  type = string
}

variable "redirect_function_name" {
  type = string
}

variable "gateway_name" {
  type = string
}

variable "gateway_domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}
