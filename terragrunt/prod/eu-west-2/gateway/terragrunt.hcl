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

inputs = {
  environment                  = include.root.locals.environment
  shorten_invoke_arn           = dependency.lambda.outputs.shorten_invoke_arn
  shorten_function_name        = dependency.lambda.outputs.shorten_function_name
  redirect_invoke_arn          = dependency.lambda.outputs.redirect_invoke_arn
  redirect_function_name       = dependency.lambda.outputs.redirect_function_name
  gateway_domain_name          = "rdrt.click"
  acm_certificate_arn          = arn:aws:acm:eu-west-2:346299179056:certificate/53dec5e5-fc57-41ba-925f-ee9b13b8157c
  stage_throttling_rate_limit  = 10
  stage_throttling_burst_limit = 15
}
