include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/gateway"
}

dependency "lambda" {
  config_path = "../lambda"
}

locals {
  gateway_name = "${include.root.locals.project_name}-${include.root.locals.environment}"
}

inputs = {
  shorten_invoke_arn           = dependency.lambda.outputs.shorten_invoke_arn
  shorten_function_name        = dependency.lambda.outputs.shorten_function_name
  redirect_invoke_arn          = dependency.lambda.outputs.redirect_invoke_arn
  redirect_function_name       = dependency.lambda.outputs.redirect_function_name
  gateway_name                 = local.gateway_name
  gateway_domain_name          = "api.rdrt.click"
  acm_certificate_arn          = "arn:aws:acm:eu-west-2:375259954999:certificate/79678a91-62a6-40c5-aa68-a674bcca43db"
  stage_throttling_rate_limit  = 10
  stage_throttling_burst_limit = 15
}
